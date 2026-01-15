/* Android config.h for iPerf3 */

#ifndef CONFIG_H
#define CONFIG_H

/* Include standard types for Android */
#include <stdint.h>
#include <sys/types.h>

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/socket.h> header file. */
#define HAVE_SYS_SOCKET_H 1

/* Define to 1 if you have the <netinet/in.h> header file. */
#define HAVE_NETINET_IN_H 1

/* Define to 1 if you have the <arpa/inet.h> header file. */
#define HAVE_ARPA_INET_H 1

/* Define to 1 if you have the <netdb.h> header file. */
#define HAVE_NETDB_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
#define HAVE_SYS_TIME_H 1

/* Define to 1 if you have the <errno.h> header file. */
#define HAVE_ERRNO_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define HAVE_STDIO_H 1

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if you have the <signal.h> header file. */
#define HAVE_SIGNAL_H 1

/* Define to 1 if you have the `socket' function. */
#define HAVE_SOCKET 1

/* Define to 1 if you have the `gettimeofday' function. */
#define HAVE_GETTIMEOFDAY 1

/* Define to 1 if you have the `select' function. */
#define HAVE_SELECT 1

/* Define to 1 if you have the `poll' function. */
#define HAVE_POLL 1

/* Define to 1 if you have the `usleep' function. */
#define HAVE_USLEEP 1

/* Define to 1 if you have the `snprintf' function. */
#define HAVE_SNPRINTF 1

/* Define to 1 if you have the `inet_ntop' function. */
#define HAVE_INET_NTOP 1

/* Define to 1 if you have the `inet_pton' function. */
#define HAVE_INET_PTON 1

/* Define to 1 if you have getaddrinfo support */
#define HAVE_GETADDRINFO 1

/* Define to 1 if you have the SO_MAX_PACING_RATE socket option. */
/* #undef HAVE_SO_MAX_PACING_RATE */

/* Define to 1 if you have the TCP_CONGESTION socket option. */
#define HAVE_TCP_CONGESTION 1

/* Define to 1 if you have the SO_REUSEPORT socket option. */
#define HAVE_SO_REUSEPORT 1

/* Define to 1 if you have the TCP_USER_TIMEOUT socket option. */
#define HAVE_TCP_USER_TIMEOUT 1

/* Define to 1 if you have SCTP support. */
/* #undef HAVE_SCTP_H */

/* iPerf3 version */
#define IPERF_VERSION "3.16"

/* Package name */
#define PACKAGE_NAME "iperf"

/* Package string */
#define PACKAGE_STRING "iperf 3.16"

/* Package version */
#define PACKAGE_VERSION "3.16"

/* Version number */
#define VERSION "3.16"

/* Define for Android compilation */
#define __ANDROID__ 1

/* Android atomic types handling */
#ifdef __has_include
#  if __has_include(<stdatomic.h>)
#    define HAVE_STDATOMIC_H 1
#  endif
#endif

/* Define MAX_OMIT_TIME */
#define MAX_OMIT_TIME 60

#endif /* CONFIG_H */