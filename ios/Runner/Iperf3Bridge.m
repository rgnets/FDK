//
//  Iperf3Bridge.m
//  Runner
//
//  ATT-FE-Tool iOS iperf3 bridge
//

#import "Iperf3Bridge.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <netdb.h>

// Import iperf3 C bridge
#import "iperf3_bridge.h"

@implementation Iperf3ResultObjC
@end

@implementation Iperf3Bridge {
    // Store context for C callbacks
    void *_progressContext;
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _progressContext = (__bridge void *)self;
    }
    return self;
}

#pragma mark - C Callback Bridge

// C function that bridges to Objective-C callback
static void iperf3_progress_callback_wrapper(void *context,
                                              int interval,
                                              long bytes_transferred,
                                              double bits_per_second,
                                              double jitter,
                                              int lost_packets,
                                              double rtt) {
    if (!context) return;

    Iperf3Bridge *bridge = (__bridge Iperf3Bridge *)context;
    if (bridge.progressCallback) {
        // Call Objective-C callback on main thread for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            bridge.progressCallback(interval,
                                   bytes_transferred,
                                   bits_per_second,
                                   jitter,
                                   lost_packets,
                                   rtt);
        });
    }
}

#pragma mark - Public Methods

- (Iperf3ResultObjC *)runClientWithHost:(NSString *)host
                                    port:(NSInteger)port
                                duration:(NSInteger)duration
                                parallel:(NSInteger)parallel
                                 reverse:(BOOL)reverse
                                  useUdp:(BOOL)useUdp
                               bandwidth:(long long)bandwidth {

    NSLog(@"Iperf3Bridge: Running client test to %@:%ld", host, (long)port);
    NSLog(@"Iperf3Bridge: Protocol: %@, Duration: %lds, Streams: %ld",
          useUdp ? @"UDP" : @"TCP", (long)duration, (long)parallel);

    // Run iperf3 test (blocking call) with progress callback
    Iperf3Result *c_result = iperf3_run_client_test(
        [host UTF8String],
        (int)port,
        (int)duration,
        (int)parallel,
        reverse ? 1 : 0,
        useUdp ? 1 : 0,
        bandwidth,
        iperf3_progress_callback_wrapper,
        _progressContext
    );

    // Convert C result to Objective-C object
    Iperf3ResultObjC *result = [[Iperf3ResultObjC alloc] init];

    if (c_result) {
        result.success = c_result->success ? YES : NO;

        if (c_result->jsonOutput) {
            result.jsonOutput = [NSString stringWithUTF8String:c_result->jsonOutput];
        }

        if (c_result->errorMessage) {
            result.errorMessage = [NSString stringWithUTF8String:c_result->errorMessage];
        }

        result.errorCode = c_result->errorCode;
        result.sendMbps = c_result->sendMbps;
        result.receiveMbps = c_result->receiveMbps;
        result.sentBytes = (long long)(c_result->sendMbps * duration * 1000000 / 8);
        result.receivedBytes = (long long)(c_result->receiveMbps * duration * 1000000 / 8);

        // Free C result structure
        iperf3_free_result(c_result);

        NSLog(@"Iperf3Bridge: Test completed - Success: %@", result.success ? @"YES" : @"NO");
        if (!result.success && result.errorMessage) {
            NSLog(@"Iperf3Bridge: Error: %@", result.errorMessage);
        }
    } else {
        result.success = NO;
        result.errorMessage = @"Failed to create iperf3 test result";
        result.errorCode = -1;
        NSLog(@"Iperf3Bridge: Failed to get result from C layer");
    }

    return result;
}

- (void)cancelClient {
    NSLog(@"Iperf3Bridge: Cancelling client test");
    iperf3_request_client_cancel();
}

- (NSString *)getVersion {
    const char *version = iperf3_get_version_string();
    if (version) {
        return [NSString stringWithUTF8String:version];
    }
    return @"Unknown";
}

- (nullable NSString *)getDefaultGateway {
    NSLog(@"Iperf3Bridge: Getting default gateway using getifaddrs");

    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *gateway = nil;
    NSString *bestInterface = nil;

    // Get list of all network interfaces
    if (getifaddrs(&interfaces) == 0) {
        temp_addr = interfaces;

        // Look for active WiFi interface (en0, en1), prioritize 192.168.x.x networks
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr && temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString *interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];

                // Only physical interfaces (en*), skip VPN (utun, ipsec, etc)
                if ([interfaceName hasPrefix:@"en"]) {
                    struct sockaddr_in *addr = (struct sockaddr_in *)temp_addr->ifa_addr;
                    struct sockaddr_in *netmask = (struct sockaddr_in *)temp_addr->ifa_netmask;

                    // Check interface is UP and RUNNING
                    if (addr && netmask && (temp_addr->ifa_flags & IFF_UP) && (temp_addr->ifa_flags & IFF_RUNNING)) {
                        // Get device IP in network byte order
                        uint32_t deviceIP = addr->sin_addr.s_addr;
                        uint32_t mask = netmask->sin_addr.s_addr;

                        // Convert to host byte order for easier manipulation
                        uint32_t deviceIPHost = ntohl(deviceIP);
                        uint32_t maskHost = ntohl(mask);

                        char deviceStr[INET_ADDRSTRLEN];
                        inet_ntop(AF_INET, &(addr->sin_addr), deviceStr, INET_ADDRSTRLEN);

                        NSLog(@"Iperf3Bridge: Checking interface %@ with IP: %s", interfaceName, deviceStr);

                        // Skip link-local addresses (169.254.x.x)
                        if ((deviceIPHost & 0xFFFF0000) == 0xA9FE0000) {
                            NSLog(@"Iperf3Bridge: Skipping link-local address on %@", interfaceName);
                            temp_addr = temp_addr->ifa_next;
                            continue;
                        }

                        // Skip loopback (127.x.x.x)
                        if ((deviceIPHost & 0xFF000000) == 0x7F000000) {
                            NSLog(@"Iperf3Bridge: Skipping loopback address on %@", interfaceName);
                            temp_addr = temp_addr->ifa_next;
                            continue;
                        }

                        // Calculate network address in host byte order
                        uint32_t networkHost = deviceIPHost & maskHost;

                        // Gateway is network address + 1
                        uint32_t gatewayHost = networkHost + 1;

                        // Convert back to network byte order
                        uint32_t gatewayAddr = htonl(gatewayHost);

                        char gatewayStr[INET_ADDRSTRLEN];
                        struct in_addr gatewayInAddr;
                        gatewayInAddr.s_addr = gatewayAddr;
                        inet_ntop(AF_INET, &gatewayInAddr, gatewayStr, INET_ADDRSTRLEN);

                        NSString *candidateGateway = [NSString stringWithUTF8String:gatewayStr];

                        // Prioritize 192.168.x.x networks (typical home WiFi)
                        bool isPrivate192 = (deviceIPHost & 0xFFFF0000) == 0xC0A80000; // 192.168.x.x

                        NSLog(@"Iperf3Bridge: Found candidate - Interface: %@, Device IP: %s, Gateway: %@, Type: %@",
                              interfaceName, deviceStr, candidateGateway, isPrivate192 ? @"192.168.x.x (Home WiFi)" : @"Other");

                        // Use this interface if we don't have one yet, OR if it's a 192.168 network
                        if (gateway == nil || isPrivate192) {
                            gateway = candidateGateway;
                            bestInterface = interfaceName;

                            // If we found a 192.168.x.x network, use it immediately
                            if (isPrivate192) {
                                NSLog(@"Iperf3Bridge: Selecting 192.168.x.x network (typical home WiFi)");
                                break;
                            }
                        }
                    }
                }
            }
            temp_addr = temp_addr->ifa_next;
        }

        freeifaddrs(interfaces);
    }

    if (gateway) {
        NSLog(@"Iperf3Bridge: Selected gateway %@ on interface %@", gateway, bestInterface);
    } else {
        NSLog(@"Iperf3Bridge: Could not determine default gateway");
    }

    return gateway;
}

- (NSDictionary *)getGatewayForDestination:(NSString *)hostname {
    NSLog(@"Iperf3Bridge: Getting gateway for destination: %@", hostname);

    // For iOS, we'll try to resolve the hostname and determine the gateway
    // based on the network interface used

    struct hostent *host = gethostbyname([hostname UTF8String]);
    if (host == NULL) {
        NSLog(@"Iperf3Bridge: Failed to resolve hostname: %@", hostname);
        return @{
            @"success": @NO,
            @"error": @"Failed to resolve hostname"
        };
    }

    // Get the default gateway (simplified approach for iOS)
    NSString *gateway = [self getDefaultGateway];

    if (gateway) {
        return @{
            @"success": @YES,
            @"gatewayAddress": gateway,
            @"networkType": @"WiFi/Cellular",
            @"interfaceName": @"en0/pdp_ip0"
        };
    } else {
        return @{
            @"success": @NO,
            @"error": @"Could not determine gateway"
        };
    }
}

@end
