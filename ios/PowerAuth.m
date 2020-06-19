/**
 * Copyright 2020 Helius Systems
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

    RCT_EXPORT_METHOD(validatePasswordCorrect:
                    (NSString*) oldPassword
                    validatePasswordCorrectResolver : (RCTPromiseResolveBlock) resolve
                    validatePasswordCorrectRejecter : (RCTPromiseRejectBlock) reject) {

        [[PowerAuthSDK sharedInstance] validatePasswordCorrect:oldPassword callback:^(NSError * _Nullable error) {
            if(error == nil) {
                NSString* successMessage = @"valid";

                resolve(successMessage);
            } else {
                reject(@"Error", error.localizedDescription, nil);
            }
        }];
    }

    RCT_EXPORT_METHOD(unsafeChangePassword:
                    (NSString*) oldPassword
                    withNewPassword: (NSString*) newPassword
                    unsafeChangePasswordResolver : (RCTPromiseResolveBlock) resolve
                    unsafeChangePasswordRejecter : (RCTPromiseRejectBlock) reject) {

        [[PowerAuthSDK sharedInstance] unsafeChangePasswordFrom: oldPassword to:newPassword];

        NSString* successMessage = @"password_changed";

        resolve(successMessage);
    }

@end
