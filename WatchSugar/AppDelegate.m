//
//  AppDelegate.m
//  WatchSugar
//
//  Created by Adam A. Wolf on 12/14/15.
//  Copyright © 2015 Flairify. All rights reserved.
//

#import "AppDelegate.h"

#import <AFNetworking/AFNetworking.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSString *dexcomToken;
@property (nonatomic, strong) NSString *subscriptionId;
@property (nonatomic, strong) NSDictionary * latestBloodSugarData;

@property (nonatomic, strong) NSTimer *fetchTimer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.fetchTimer) {
        [self.fetchTimer invalidate];
        self.fetchTimer = nil;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (!self.dexcomToken) {
        [self authenticateWithDexcom];
    }
    
    self.fetchTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(fetchTimerFired:) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Helper methods

- (void)fetchTimerFired:(NSTimer *)timer
{
    if (!self.dexcomToken) {
        [self authenticateWithDexcom];
    } else {
        if (!self.subscriptionId) {
            [self fetchSubscriptions];
        } else {
            [self fetchLatestBloodSugar];
        }
    }
}

+ (void)dexcomPOSTToURLString:(NSString *)URLString
               withParameters:(id)parameters
             withSuccessBlock:(void (^)(NSURLSessionDataTask *, id))success
             withFailureBlock:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"Dexcom Share/3.0.2.11 CFNetwork/711.2.23 Darwin/14.0.0" forHTTPHeaderField:@"User-Agent"];
    [manager setRequestSerializer:requestSerializer];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager setResponseSerializer:responseSerializer];
    
    [manager POST:URLString parameters:parameters progress:NULL success:success failure:failure];
}

- (void)authenticateWithDexcom
{
    NSString *URLString = @"https://share1.dexcom.com/ShareWebServices/Services/General/LoginSubscriberAccount";
    NSDictionary *parameters = @{@"accountId": @"***REMOVED***",
                                 @"password": @"A***REMOVED***",
                                 @"applicationId": @"d89443d2-327c-4a6f-89e5-496bbb0317db"};
    
    [AppDelegate dexcomPOSTToURLString:URLString
                        withParameters:parameters
                      withSuccessBlock:^(NSURLSessionDataTask * task, id responseObject) {
                          NSLog(@"received dexcom token: %@", responseObject);
                          self.dexcomToken = responseObject;
                          
                          if (!self.subscriptionId) {
                              [self fetchSubscriptions];
                          }
                      }
                      withFailureBlock:^(NSURLSessionDataTask * task, NSError * error) {
                          NSLog(@"error: %@", error);
                      }];
}

- (void)fetchSubscriptions
{
    NSString *URLString = [NSString stringWithFormat:@"https://share1.dexcom.com/ShareWebServices/Services/Subscriber/ListSubscriberAccountSubscriptions?sessionId=%@", self.dexcomToken];
    NSString *parameters = nil;
    
    [AppDelegate dexcomPOSTToURLString:URLString
                        withParameters:parameters
                      withSuccessBlock:^(NSURLSessionDataTask * task, id responseObject) {
                          NSLog(@"received subscription list: %@", responseObject);
                          self.subscriptionId = responseObject[0][@"SubscriptionId"];
                          
                          if (!self.latestBloodSugarData) {
                              [self fetchLatestBloodSugar];
                          }
                      }
                      withFailureBlock:^(NSURLSessionDataTask * task, NSError * error) {
                          NSLog(@"error: %@", error);
                      }];
}

- (void)fetchLatestBloodSugar
{
    NSString *URLString = [NSString stringWithFormat:@"https://share1.dexcom.com/ShareWebServices/Services/Subscriber/ReadLastGlucoseFromSubscriptions?sessionId=%@", self.dexcomToken];
    NSArray *parameters = @[self.subscriptionId];
    
    [AppDelegate dexcomPOSTToURLString:URLString
                        withParameters:parameters
                      withSuccessBlock:^(NSURLSessionDataTask * task, id responseObject) {
                          NSLog(@"received blood sugar data: %@", responseObject);
                          self.latestBloodSugarData = responseObject[0];
                      }
                      withFailureBlock:^(NSURLSessionDataTask * task, NSError * error) {
                          NSLog(@"error: %@", error);
                      }];
}

@end
