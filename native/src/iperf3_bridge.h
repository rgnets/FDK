#ifndef IPERF3_BRIDGE_H
#define IPERF3_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

// Forward declaration of callback function type
typedef void (*ProgressCallback)(void* context, int interval, long bytesTransferred,
                                 double bitsPerSecond, double jitter, int lostPackets, double rtt);

// Result structure returned from iperf3 tests
typedef struct {
    int success;                    // 1 if test succeeded, 0 if failed
    double sentBitsPerSecond;       // Send speed in bits/sec
    double receivedBitsPerSecond;   // Receive speed in bits/sec
    double sendMbps;                // Send speed in Mbps
    double receiveMbps;             // Receive speed in Mbps
    double rtt;                     // Round-trip time in ms (TCP)
    double jitter;                  // Jitter in ms (UDP)
    int lostPackets;                // Lost packets (UDP)
    int totalPackets;               // Total packets (UDP)
    char* jsonOutput;               // Full JSON output from iperf3
    char* errorMessage;             // Error message if failed
    int errorCode;                  // Error code if failed
} Iperf3Result;

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
);

// Request cancellation of running client test
void iperf3_request_client_cancel();

// Start iperf3 server
int iperf3_start_server_test(int port, int useUdp);

// Stop iperf3 server
int iperf3_stop_server_test();

// Get iperf3 version string
const char* iperf3_get_version_string();

// Free result structure
void iperf3_free_result(Iperf3Result* result);

#ifdef __cplusplus
}
#endif

#endif // IPERF3_BRIDGE_H
