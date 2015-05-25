//
//  YJAppDelegate.m
//  SMS_SDKDemo
//
//  Created by 刘 靖煌 on 14-8-28.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "YJAppDelegate.h"
#import "YJViewController.h"

#import <SMS_SDK/SMS_SDK.h>

#define appKey @"4d90f19ede24"
#define appSecret @"a239033c4182defcd93eaabd054c25d6"

@implementation YJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //初始化应用，appKey和appSecret从后台申请得到
    [SMS_SDK registerApp:appKey
              withSecret:appSecret];
    
    //[SMS_SDK enableAppContactFriends:NO];
    
    YJViewController* yj=[[YJViewController alloc] init];
    self.window.rootViewController=yj;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
