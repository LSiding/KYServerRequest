//
//  KYServerRequest.h
//  TestDemo
//
//  Created by Siding on 2019/1/26.
//  Copyright © 2019 Siding. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const KYServerRequestErrorDomain;

typedef NS_ENUM(NSUInteger, KYServerRequestErrorCode) {
    KYServerRequestErrorCodeForOvertime,
    KYServerRequestErrorCodeForMissConnection,
};

typedef void (^KYServerRequestBlock)(void);
typedef void (^KYServerRequestSuccessBlock)(NSNotification *notification, BOOL *stop);
typedef void (^KYServerRequestFailureBlock)(NSError *error, BOOL *stop);

@interface KYServerRequest : NSObject

- (void)requestWithNotificationName:(NSString *)notificationName
                           overtime:(double)overtime
                            request:(KYServerRequestBlock)request
                            success:(KYServerRequestSuccessBlock)success
                            failure:(KYServerRequestFailureBlock)failure;

@end
