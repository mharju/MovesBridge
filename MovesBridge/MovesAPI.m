//
//  MovesAPI.m
//  MovesAnalysis
//
//  Created by Mikko Harju on 4.5.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#import "AFNetworking.h"
#import "MovesAPI.h"
#import "MovesAPI+Private.h"
#import "MovesAPI+InternalAccessTokenRequester.h"

static void (^authorizationSuccessCallback)();
static void (^authorizationFailureCallback)(NSError *reason);

@implementation MovesAPI
+ (MovesAPI*)sharedInstance {
    static MovesAPI *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MovesAPI alloc] init];
    });
    
    return _sharedClient;
}

- (id) init
{
    if(self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.moves-app.com/"]]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.accessToken = [defaults objectForKey:@"AccessToken"];
        self.fetchTime = (NSDate*) [defaults objectForKey:@"FetchTime"];
        self.expiry = (NSNumber*) [defaults objectForKey:@"Expires"];
    }
    return self;
}

#pragma mark General methods appending authorization key to requests

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    // TODO fix this to work with arbitraty request params
    NSString *authorizedPath = [path stringByAppendingFormat:@"?access_token=%@", self.accessToken];
    
    [super getPath:authorizedPath parameters:parameters
           success:success failure:failure];
}

#pragma mark OAuth2 authentication with Moves app

- (void) performAuthorization:(void (^)())success failure:(void (^)(NSError *reason))failure
{
    if(self.hasValidAccessToken) {
        success();
    } else {
        authorizationSuccessCallback = success;
        authorizationFailureCallback = failure;
        
        NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"moves://app/authorize?client_id=%@&redirect_uri=%@&scope=activity%%20location", kOauthClientId, kOauthRedirectUri]];
        [[UIApplication sharedApplication] openURL:authUrl];
    }
}

- (void)authorizationCompletedCallback:(NSURL*)responseUrl
{
    NSArray *keysAndObjs = [[responseUrl.query stringByReplacingOccurrencesOfString:@"=" withString:@"&"] componentsSeparatedByString:@"&"];
    
    for(int i=0;i<keysAndObjs.count;i+=2) {
        NSString *key = keysAndObjs[i];
        NSString *value = keysAndObjs[i+1];
        
        if([key isEqualToString:@"code"]) {
            [self requestOrRefreshAccessToken:value complete:^{
                authorizationSuccessCallback();
                authorizationSuccessCallback = nil;
                authorizationFailureCallback = nil;
            } failure:^(NSError *reason) {
                authorizationFailureCallback(reason);
                authorizationFailureCallback = nil;
                authorizationSuccessCallback = nil;
            }];
            break;
        } else if([key isEqualToString:@"error"]) {
            authorizationFailureCallback([NSError errorWithDomain:@"moves-bridge" code:0 userInfo:@{@"description": value}]);
            authorizationSuccessCallback = nil;
            authorizationFailureCallback = nil;
        }
    }
}


- (void) updateUserDefaultsWithAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken andExpiry:(NSNumber*)expiry {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:@"AccessToken"];
    [defaults setObject:refreshToken forKey:@"RefreshToken"];
    [defaults setObject:expiry forKey:@"Expires"];
    [defaults setObject:[NSDate date] forKey:@"FetchTime"];
    
    [defaults synchronize];
}

- (BOOL)hasValidAccessToken
{
    if(self.accessToken) {
        NSLog(@"WE have a valid access token: %@", self.accessToken);

        return [[NSDate date] compare:[self.fetchTime dateByAddingTimeInterval:[self.expiry doubleValue]]] == NSOrderedAscending;
    }
    return NO;
}

@end
