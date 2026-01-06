/*
 * Simple iperf error handling for iOS
 */
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <pthread.h>
#include "iperf.h"
#include "iperf_api.h"

int gerror = 0;
int i_errno = IENONE;
char iperf_timestrerr[100];

static pthread_mutex_t error_mutex = PTHREAD_MUTEX_INITIALIZER;

/* Do a printf to stderr. */
void
iperf_err(struct iperf_test *test, const char *format, ...)
{
    va_list argp;
    char str[1000];

    pthread_mutex_lock(&error_mutex);

    va_start(argp, format);
    vsnprintf(str, sizeof(str), format, argp);
    va_end(argp);

    if (test != NULL && test->logfile != NULL) {
        fprintf(test->logfile, "%s", str);
        fflush(test->logfile);
    } else {
        fprintf(stderr, "%s", str);
    }

    pthread_mutex_unlock(&error_mutex);
}

/* Do a printf to stderr and exit. */
void
iperf_errexit(struct iperf_test *test, const char *format, ...)
{
    va_list argp;
    char str[1000];

    va_start(argp, format);
    vsnprintf(str, sizeof(str), format, argp);
    va_end(argp);

    if (test != NULL && test->logfile != NULL) {
        fprintf(test->logfile, "%s", str);
        fflush(test->logfile);
    } else {
        fprintf(stderr, "%s", str);
    }

    exit(1);
}

void
iperf_exit(struct iperf_test *test, int status)
{
    exit(status);
}

char *
iperf_strerror(int int_errno)
{
    static char errstr[256];
    int len, perr, herr;

    len = sizeof(errstr);
    memset(errstr, 0, len);

    switch (int_errno) {
    case IENONE:
        snprintf(errstr, len, "no error");
        break;
    case IENEWTEST:
        snprintf(errstr, len, "unable to create a new test");
        perr = 1;
        break;
    case IEINITTEST:
        snprintf(errstr, len, "test initialization failed");
        break;
    case IELISTEN:
        snprintf(errstr, len, "unable to listen for connections");
        perr = 1;
        break;
    case IECONNECT:
        snprintf(errstr, len, "unable to connect to server");
        perr = 1;
        break;
    case IEACCEPT:
        snprintf(errstr, len, "unable to accept connection from client");
        perr = 1;
        break;
    case IESENDCOOKIE:
        snprintf(errstr, len, "unable to send cookie to server");
        perr = 1;
        break;
    case IERECVCOOKIE:
        snprintf(errstr, len, "unable to receive cookie at server");
        perr = 1;
        break;
    case IECTRLWRITE:
        snprintf(errstr, len, "unable to write to the control socket");
        perr = 1;
        break;
    case IECTRLREAD:
        snprintf(errstr, len, "unable to read from the control socket");
        perr = 1;
        break;
    case IECTRLCLOSE:
        snprintf(errstr, len, "control socket has closed unexpectedly");
        break;
    case IEMESSAGE:
        snprintf(errstr, len, "received an unknown message");
        break;
    case IESENDMESSAGE:
        snprintf(errstr, len, "unable to send control message");
        perr = 1;
        break;
    case IERECVMESSAGE:
        snprintf(errstr, len, "unable to receive control message");
        perr = 1;
        break;
    case IESENDPARAMS:
        snprintf(errstr, len, "unable to send parameters to server");
        perr = 1;
        break;
    case IERECVPARAMS:
        snprintf(errstr, len, "unable to receive parameters from client");
        perr = 1;
        break;
    case IEPACKAGERESULTS:
        snprintf(errstr, len, "unable to package results");
        perr = 1;
        break;
    case IESENDRESULTS:
        snprintf(errstr, len, "unable to send results");
        perr = 1;
        break;
    case IERECVRESULTS:
        snprintf(errstr, len, "unable to receive results");
        perr = 1;
        break;
    case IESELECT:
        snprintf(errstr, len, "select failed");
        perr = 1;
        break;
    case IECLIENTTERM:
        snprintf(errstr, len, "the client has terminated");
        break;
    case IESERVERTERM:
        snprintf(errstr, len, "the server has terminated");
        break;
    case IEACCESSDENIED:
        snprintf(errstr, len, "the server is busy running a test. try again later");
        break;
    case IENOSCTP:
        snprintf(errstr, len, "SCTP not supported");
        break;
    case IEUNIMP:
        snprintf(errstr, len, "function not implemented");
        break;
    /* Stream errors (200-series) */
    case IEINITSTREAM:
        snprintf(errstr, len, "unable to initialize stream");
        perr = 1;
        break;
    case IESTREAMLISTEN:
        snprintf(errstr, len, "unable to start stream listener");
        perr = 1;
        break;
    case IESTREAMCONNECT:
        snprintf(errstr, len, "unable to connect stream");
        perr = 1;
        break;
    case IESTREAMACCEPT:
        snprintf(errstr, len, "unable to accept stream connection");
        perr = 1;
        break;
    case IESTREAMWRITE:
        snprintf(errstr, len, "unable to write to stream socket");
        perr = 1;
        break;
    case IESTREAMREAD:
        snprintf(errstr, len, "unable to read from stream (check network/firewall)");
        perr = 1;
        break;
    case IESTREAMCLOSE:
        snprintf(errstr, len, "stream has closed unexpectedly");
        break;
    case IESTREAMID:
        snprintf(errstr, len, "stream has invalid ID");
        break;
    /* Timer errors (300-series) */
    case IENEWTIMER:
        snprintf(errstr, len, "unable to create new timer");
        perr = 1;
        break;
    case IEUPDATETIMER:
        snprintf(errstr, len, "unable to update timer");
        perr = 1;
        break;
    default:
        snprintf(errstr, len, "unknown error (code=%d)", int_errno);
        break;
    }

    return errstr;
}