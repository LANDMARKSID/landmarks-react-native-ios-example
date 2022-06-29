//
//  LandmarksIdLOD.m
//  LandmarksIdLod
//
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNLandmarksIdLOD, NSObject)

    RCT_EXTERN_METHOD(initialiseSDK:(NSString*)appId appSecret:(NSString*)appSecret apiKey:(NSString*)apiKey debugMode:(BOOL)debugMode);

    RCT_EXTERN_METHOD(startTracking);
    RCT_EXTERN_METHOD(stopTracking);
    RCT_EXTERN_METHOD(terminate);

    RCT_EXTERN_METHOD(requestLocationPermission);

    RCT_EXTERN_METHOD(restartRecordingData);
    RCT_EXTERN_METHOD(stopRecordingData);

    RCT_EXTERN_METHOD(setCustomerId:(NSString*)customerId);
    RCT_EXTERN_METHOD(sendCustomString:(NSString*)key value:(NSString *)value);
    RCT_EXTERN_METHOD(sendCustomInteger:(NSString*)key value:(nonnull NSNumber *)value);
    RCT_EXTERN_METHOD(sendCustomFloat:(NSString*)key value:(nonnull NSNumber *)value);

@end
