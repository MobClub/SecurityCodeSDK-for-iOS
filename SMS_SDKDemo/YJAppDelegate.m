//
//  YJAppDelegate.m
//  SMS_SDKDemo
//
//  Created by 刘靖煌 on 14-8-28.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "YJAppDelegate.h"
#import "SMS_SDK/SMS_SDK.h"
#import "YJViewController.h"

#define appKey @"25a64c839b5f"
#define appSecret @"9a639150fcb464d9a1c1ab926648ca3f"

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
