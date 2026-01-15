#include "iperf3_bridge.h"
#include "iperf.h"
#include "iperf_api.h"
#include "version.h"
#include "cJSON.h"
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <netinet/in.h>

#ifdef ANDROID
#include <android/log.h>
#define LOG_TAG "iperf3_bridge"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#else
#include <stdio.h>
#define LOGD(...) printf(__VA_ARGS__); printf("\n")
#define LOGI(...) printf(__VA_ARGS__); printf("\n")
#define LOGW(...) fprintf(stderr, "WARN: " __VA_ARGS__); fprintf(stderr, "\n")
#define LOGE(...) fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\n")
#endif

// Global client state management for cancellation
static pthread_mutex_t g_client_mutex = PTHREAD_MUTEX_INITIALIZER;
static struct iperf_test* g_active_client_test = NULL;
static volatile int g_cancel_client_requested = 0;

// Request cancellation
void iperf3_request_client_cancel() {
    pthread_mutex_lock(&g_client_mutex);
    if (g_active_client_test) {
        LOGI("Cancellation requested - signalling active iperf3 client to stop");
        g_cancel_client_requested = 1;
        g_active_client_test->done = 1;
        iperf_set_test_state(g_active_client_test, CLIENT_TERMINATE);
        if (iperf_set_send_state(g_active_client_test, CLIENT_TERMINATE) != 0) {
            LOGW("Failed to send CLIENT_TERMINATE state to server: %s",
                 iperf_strerror(i_errno));
        }
    } else {
        LOGD("Cancellation requested but no active client test is running");
    }
    pthread_mutex_unlock(&g_client_mutex);
}

// Get iperf3 version
const char* iperf3_get_version_string() {
    return IPERF_VERSION;
}

// Free result structure
void iperf3_free_result(Iperf3Result* result) {
    if (result) {
        if (result->jsonOutput) {
            free(result->jsonOutput);
        }
        if (result->errorMessage) {
            free(result->errorMessage);
        }
        free(result);
    }
}

// Progress callback context for reporter (stored globally for the duration of one test)
static ProgressCallback g_progress_callback = NULL;
static void* g_progress_callback_context = NULL;
static void (*g_original_reporter_callback)(struct iperf_test*) = NULL;
static int g_last_reported_interval = 0;

// Helper: Get number from JSON object with default value
static double get_json_number(cJSON* obj, const char* key, double defaultValue) {
    if (!obj) return defaultValue;
    cJSON* item = cJSON_GetObjectItemCaseSensitive(obj, key);
    if (!item) return defaultValue;
    if (cJSON_IsNumber(item)) return item->valuedouble;
    return defaultValue;
}

// Helper: Get the "sum" object from an interval
// Tries fallback hierarchy: sum → sum_sent → sum_received
// The "sum" object contains pre-aggregated metrics from iperf3
static cJSON* get_interval_sum(cJSON* interval) {
    if (!interval) return NULL;

    // Try sum objects in priority order (matches GitHub reference)
    cJSON* sum = cJSON_GetObjectItemCaseSensitive(interval, "sum");
    if (!sum) {
        sum = cJSON_GetObjectItemCaseSensitive(interval, "sum_sent");
    }
    if (!sum) {
        sum = cJSON_GetObjectItemCaseSensitive(interval, "sum_received");
    }

    return sum;
}

static void reporter_callback(struct iperf_test *test) {
    if (g_original_reporter_callback) {
        g_original_reporter_callback(test);
    }

    if (!test || !g_progress_callback) {
        return;
    }

    if (g_cancel_client_requested) {
        iperf_set_test_state(test, IPERF_DONE);
        return;
    }

    if (!test->json_intervals) {
        return;
    }

    int interval_count = cJSON_GetArraySize(test->json_intervals);
    if (interval_count <= g_last_reported_interval) {
        return;
    }

    for (int idx = g_last_reported_interval; idx < interval_count; idx++) {
        cJSON* interval = cJSON_GetArrayItem(test->json_intervals, idx);
        if (!interval) continue;

        cJSON* sum = get_interval_sum(interval);
        if (!sum) continue;

        double bytes = get_json_number(sum, "bytes", 0.0);
        double bits_per_second = get_json_number(sum, "bits_per_second", 0.0);
        double jitter = get_json_number(sum, "jitter_ms", 0.0);
        int lost_packets = (int)get_json_number(sum, "lost_packets", 0.0);

        g_progress_callback(
            g_progress_callback_context,
            idx + 1,
            (long)bytes,
            bits_per_second,
            jitter,
            lost_packets,
            0.0
        );
    }

    g_last_reported_interval = interval_count;
}

// Run iperf3 client test
Iperf3Result* iperf3_run_client_test(
    const char* host,
    int port,
    int duration,
    int parallel,
    int reverse,
    int useUdp,
    long bandwidth,
    ProgressCallback callback,
    void* callbackContext
) {
    Iperf3Result* result = (Iperf3Result*)calloc(1, sizeof(Iperf3Result));
    if (!result) {
        LOGE("Failed to allocate result structure");
        return NULL;
    }

    // Create iperf3 test structure
    struct iperf_test* test = iperf_new_test();
    if (!test) {
        LOGE("Failed to create iperf3 test");
        result->success = 0;
        result->errorMessage = strdup("Failed to create test");
        result->errorCode = -1;
        return result;
    }

    iperf_defaults(test);
    test->settings->domain = AF_INET;
    iperf_set_test_connect_timeout(test, 5000);  // 5 seconds for faster failure detection

    if (callback) {
        g_progress_callback = callback;
        g_progress_callback_context = callbackContext;
        g_last_reported_interval = 0;
        g_original_reporter_callback = test->reporter_callback;
        test->reporter_callback = reporter_callback;
    }

    iperf_set_test_role(test, 'c');
    iperf_set_test_server_hostname(test, host);
    iperf_set_test_server_port(test, port);
    iperf_set_test_duration(test, duration);
    iperf_set_test_num_streams(test, parallel);

    if (useUdp) {
        iperf_set_test_blksize(test, 0);
        set_protocol(test, Pudp);
        test->settings->rate = bandwidth > 0 ? bandwidth : 1000000;
    } else {
        set_protocol(test, Ptcp);
        if (bandwidth > 0) {
            test->settings->rate = bandwidth;
        }
    }

    if (reverse) {
        iperf_set_test_reverse(test, 1);
    }

    iperf_set_test_json_output(test, 1);

    pthread_mutex_lock(&g_client_mutex);
    g_active_client_test = test;
    g_cancel_client_requested = 0;
    pthread_mutex_unlock(&g_client_mutex);

    i_errno = IENONE;
    int result_code = iperf_run_client(test);
    int final_errno = i_errno;

    pthread_mutex_lock(&g_client_mutex);
    int was_cancelled = g_cancel_client_requested;
    g_active_client_test = NULL;
    g_cancel_client_requested = 0;
    pthread_mutex_unlock(&g_client_mutex);

    if (was_cancelled) {
        result->success = 0;
        result->errorMessage = strdup("Test cancelled by user");
        result->errorCode = -999;
    } else if (result_code == 0 && final_errno == 0) {
        result->success = 1;

        int json_result = iperf_json_finish(test);
        if (json_result < 0) {
            LOGW("iperf_json_finish returned %d", json_result);
        }

        char* json_output = iperf_get_test_json_output_string(test);
        if (json_output) {
            result->jsonOutput = strdup(json_output);
        } else {
            LOGE("No JSON output available");
            result->success = 0;
            result->errorMessage = strdup("No JSON output available");
            result->errorCode = -1;
        }
    } else if (result_code == 0 && final_errno != 0) {
        char* error = iperf_strerror(final_errno);
        result->errorMessage = error ? strdup(error) : strdup("Test encountered an error");
        result->success = 0;
        result->errorCode = final_errno;
    } else {
        char* error = iperf_strerror(final_errno);
        result->errorMessage = error ? strdup(error) : strdup("iperf3 test failed");
        result->success = 0;
        result->errorCode = final_errno;
    }

    g_progress_callback = NULL;
    g_progress_callback_context = NULL;
    g_original_reporter_callback = NULL;
    g_last_reported_interval = 0;

    iperf_free_test(test);

    return result;
}

int iperf3_start_server_test(int port, int useUdp) {
    return 0;
}

int iperf3_stop_server_test() {
    return 0;
}
