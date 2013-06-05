//
//  MovesAPI+Private.h
//  MovesBridge
//
//  Created by Mikko Harju on 5.6.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#ifndef MovesBridge_MovesAPI_Private_h
#define MovesBridge_MovesAPI_Private_h

@interface MovesAPI ()
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSDate *fetchTime;
@property (strong, nonatomic) NSNumber *expiry;

- (BOOL)hasValidAccessToken;
- (void) updateUserDefaultsWithAccessToken:(NSString*)accessToken refreshToken:(NSString*)refreshToken andExpiry:(NSNumber*)expiry;
@end

#endif
