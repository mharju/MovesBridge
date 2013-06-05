//
//  MovesAPI+InternalAccessTokenRequester.h
//  MovesBridge
//
//  Created by Mikko Harju on 5.6.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#import "MovesAPI.h"
#import "MovesAPI+Private.h"

@interface MovesAPI (InternalAccessTokenRequester)
- (void)requestOrRefreshAccessToken:(NSString*)code complete:(void (^)())complete failure:(void (^)(NSError* reason))failure;
@end
