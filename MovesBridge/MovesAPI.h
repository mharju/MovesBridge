//
//  MovesAPI.h
//  MovesAnalysis
//
//  Created by Mikko Harju on 4.5.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#import "AFHTTPClient.h"

// Set keys to match your API settings here
#import "client-secret.h"

// Authorization redirect URI. Do not change!
#define kOauthRedirectUri @"moves-bridge%3A%2F%2Fauthorization-completed"

@interface MovesAPI : AFHTTPClient
+ (MovesAPI*)sharedInstance;

- (void)authorizationCompletedCallback:(NSURL*)responseUrl;
- (void) performAuthorization:(void (^)())success failure:(void (^)(NSError *reason))failure;
@end
