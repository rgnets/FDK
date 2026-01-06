//
//  Iperf3Plugin.h
//  Runner
//
//  ATT-FE-Tool iOS iperf3 integration
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/// Flutter plugin for iperf3 integration
@interface Iperf3Plugin : NSObject<FlutterPlugin, FlutterStreamHandler>

/// Register plugin with Flutter engine
/// @param registrar Flutter plugin registrar
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

@end

NS_ASSUME_NONNULL_END
