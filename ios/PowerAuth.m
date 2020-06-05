//
//  PowerAuth.m
//
//  Created by User on 6.5.20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "PowerAuth.h"
#import "UIKit/UIKit.h"

#import <PowerAuth2/PowerAuthSDK.h>


@implementation PowerAuth
    RCT_EXPORT_MODULE();


  RCT_EXPORT_METHOD(createActivation:
                  (NSDictionary*) credentials
                  createActivationResolver: (RCTPromiseResolveBlock) resolve
                  createActivationRejecter: (RCTPromiseRejectBlock) reject) {

     NSString* deviceName = [[UIDevice currentDevice] name];

    [[PowerAuthSDK sharedInstance] createActivationWithName: deviceName identityAttributes:credentials extras: nil callback:^(PA2ActivationResult * _Nullable result, NSError * _Nullable error) {

         if(error == nil) {
           NSString *successMessage = @"OK";
          
           resolve(successMessage);
         } else {
           reject(@"Error", error.localizedDescription, nil);
         }
     }];
  }

  RCT_EXPORT_METHOD(commitActivation:
                    (NSString*) password
                    commitActivationResolver: (RCTPromiseResolveBlock) resolve
                    commitActivationRejecter: (RCTPromiseRejectBlock) reject) {
    
    NSError* errorMessage = [NSError errorWithDomain:@"com.heliussystems.PowerauthReact" code:200 userInfo:@{NSLocalizedDescriptionKey: @"Commit activation was completed successfully."}];
    
    bool success = [[PowerAuthSDK sharedInstance] commitActivationWithPassword:password error: &errorMessage];
    
    if(success) {
      resolve(@"SUCCESS");
    } else {
      reject(@"error", errorMessage.localizedDescription, nil);
    }
    
  }

  RCT_EXPORT_METHOD(removeActivationLocal) {
    NSLog(@"REMOVED ACTIVATION");
    [[PowerAuthSDK sharedInstance] removeActivationLocal];
  }

  RCT_REMAP_METHOD(hasValidActivation,
                    hasValidActivationResolver: (RCTPromiseResolveBlock) resolve
                    hasValidActivationRejecter: (RCTPromiseRejectBlock) reject) {
    
    bool validActivation = [[PowerAuthSDK sharedInstance] hasValidActivation];
    
    if(validActivation) {
      resolve(@YES);
    } else {
      reject(@"400", @"false", nil);
    }
  }

RCT_REMAP_METHOD(fetchActivationStatus,
                fetchActivationStatusResolver: (RCTPromiseResolveBlock) resolve
                fetchActivationStatusRejecter: (RCTPromiseRejectBlock) reject) {
  
  bool validActivation = [[PowerAuthSDK sharedInstance] hasValidActivation];
  
  NSLog(@"VALID ACTIVATION STATUS: %d\n", validActivation);
  
  if(!validActivation) {
    reject(@"400", @"Activation is invalid", nil);
    return;
  }
  
  [[PowerAuthSDK sharedInstance] fetchActivationStatusWithCallback:^(PA2ActivationStatus * _Nullable status, NSDictionary * _Nullable customObject, NSError * _Nullable error) {
    
    if(error == nil) {
      PA2ActivationState state = status.state;
      
      int currentFailCount = status.failCount;
      int maxAllowedFailCount = status.maxFailCount;
      int remainingFailCount = maxAllowedFailCount - currentFailCount;
      
      NSDictionary *response = @{
        @"status": @(state),
        @"currentFailCount": @(currentFailCount),
        @"maxAllowedFailCount": @(maxAllowedFailCount),
        @"remainingFailCount" : @(remainingFailCount)
      };
      
      resolve(response);

      
    } else {
      // network error occured, report it to the user
      
      reject(@"400", @"Fetch activation status failed", nil);
      
    }
  }];
}

RCT_EXPORT_METHOD(requestSignature:
                  (NSString*) userPassword
                  withRequestmethod: (NSString*) requestMethod
                          withUriId: (NSString*) uriId
                    withRequestData: (NSDictionary*) reqData
                  requestSignatureResolver : (RCTPromiseResolveBlock) resolve
                  requestSignature : (RCTPromiseRejectBlock) reject) {
  
  PowerAuthAuthentication *auth = [[PowerAuthAuthentication alloc] init];
  auth.usePossession = true;
  auth.usePassword = userPassword;
  auth.useBiometry = false;
  
  NSData* requestData = [NSKeyedArchiver archivedDataWithRootObject:reqData];
  
  NSLog(@"Request data log: %@", requestData);
  
  @try {
    NSError* errorMessage = [NSError errorWithDomain:@"com.heliussystems.eposta" code:200 userInfo:@{NSLocalizedDescriptionKey: @""}];
    
   PA2AuthorizationHttpHeader* signature = [[PowerAuthSDK sharedInstance] requestSignatureWithAuthentication:auth method:requestMethod uriId:uriId body:requestData error: &errorMessage];
    
    NSDictionary *response = @{
      @"httpHeaderKey": signature.key,
      @"httpHeaderValue": signature.value
    };
    
    return resolve(response);
    
  } @catch (NSException *exception) {
    return reject(@"Error", exception.reason, nil);
  }
}

@end
