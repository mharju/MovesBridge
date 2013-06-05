//
//  MovesAPI+InternalAccessTokenRequester.m
//  MovesBridge
//
//  Created by Mikko Harju on 5.6.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#import "AFNetworking.h"
#import "MovesAPI+InternalAccessTokenRequester.h"

@implementation MovesAPI (InternalAccessTokenRequester)
- (void)requestOrRefreshAccessToken:(NSString*)code complete:(void (^)())complete failure:(void (^)(NSError* reason))failure
{
    NSString *path = [NSString stringWithFormat:@"/oauth/v1/access_token?grant_type=authorization_code&code=%@&client_id=%@&client_secret=%@&redirect_uri=%@", code, kOauthClientId, kOauthClientSecret, kOauthRedirectUri];
    
    if(self.accessToken) {
        path = [NSString stringWithFormat:@"/oauth/v1/access_token?grant_type=refresh_token&refresh_token=%@&client_id=%@&client_secret=%@",
                self.refreshToken, kOauthClientId, kOauthClientSecret];
    }
    
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateUserDefaultsWithAccessToken:responseObject[@"access_token"]
                                   refreshToken:responseObject[@"refresh_token"]
                                      andExpiry:responseObject[@"expires_in"]];
        complete();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.userInfo);
        failure(error);
    }];
}


@end
