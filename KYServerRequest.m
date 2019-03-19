//
//  KYServerRequest.m
//  TestDemo
//
//  Created by Siding on 2019/1/26.
//  Copyright © 2019 Siding. All rights reserved.
//

#import "KYServerRequest.h"

#import "YYWeakProxy.h"

NSString *const KYServerRequestErrorDomain = @"KYServerRequestErrorDomain";

@interface KYServerRequest ()

@property (copy, nonatomic)     KYServerRequestBlock requestBlock;
@property (copy, nonatomic)     KYServerRequestSuccessBlock successBlock;
@property (copy, nonatomic)     KYServerRequestFailureBlock failureBlock;

@property (copy, nonatomic)     NSNotificationName notificationName;

@property (strong, nonatomic)   NSTimer *timerForOvertime;
@property (assign, nonatomic)   double overtime;

@end

@implementation KYServerRequest

- (void)requestWithNotificationName:(NSString *)notificationName
                           overtime:(double)overtime
                            request:(KYServerRequestBlock)request
                            success:(KYServerRequestSuccessBlock)success
                            failure:(KYServerRequestFailureBlock)failure {
    self.notificationName = notificationName;
    self.overtime = overtime;
    self.requestBlock = request;
    self.successBlock = success;
    self.failureBlock = failure;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (BOOL)missConnection {
    //TODO
    return NO;
}

- (void)startRequest {
    if ([self missConnection]) {
        [self handleMissConnection];
        return;
    }
    
    [self endRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:_notificationName object:nil];
    
    if (_timerForOvertime) {
        _timerForOvertime = [NSTimer timerWithTimeInterval:_overtime target:[YYWeakProxy proxyWithTarget:self] selector:@selector(handleOvertime) userInfo:nil repeats:NO];
    }
    
    if (_requestBlock) {
        _requestBlock();
    }
}

- (void)endRequest {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:_notificationName object:nil];
    
    if (_timerForOvertime) {
        [_timerForOvertime invalidate];
        _timerForOvertime = nil;
    }
}

#pragma mark -

- (void)handleNotification:(NSNotification *)notification {
    BOOL stop = YES;
    if (_successBlock) {
        _successBlock(notification, &stop);
    }
    
    if (stop) {
        [self endRequest];
    }
}

#pragma mark - Error

- (NSError *)errorWithCode:(KYServerRequestErrorCode)code {
    return [NSError errorWithDomain:KYServerRequestErrorDomain code:code userInfo:nil];
}

- (void)handlerErrorWithCode:(KYServerRequestErrorCode)code {
    NSError *error = [self errorWithCode:code];
    
    BOOL stop = YES;
    if (_failureBlock) {
        _failureBlock(error, &stop);
    }
    
    if (stop) {
        [self endRequest];
    }
}

- (void)handleOvertime {
    [self handlerErrorWithCode:KYServerRequestErrorCodeForOvertime];
}

- (void)handleMissConnection {
    [self handlerErrorWithCode:KYServerRequestErrorCodeForMissConnection];
}

@end
