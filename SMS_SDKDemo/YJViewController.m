//
//  YJViewController.m
//  SMS_SDKDemo
//
//  Created by 刘靖煌 on 14-6-27.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "YJViewController.h"

#import "SMS_SDK/SMS_SDK.h"
#import "SMS_HYZBadgeView.h"
#import "RegViewController.h"
#import "SectionsViewControllerFriends.h"
#import "SMS_MBProgressHUD+Add.h"
#import <AddressBook/AddressBook.h>

@interface YJViewController ()
{
    SMS_HYZBadgeView* _testView;
    SectionsViewControllerFriends* _friendsController;
}

@end

static UIAlertView* _alert1=nil;

@implementation YJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat statusBarHeight=0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight=20;
    }
    
    NSString *icon = [NSString stringWithFormat:@"smssdk.bundle/button5.png"];
    
    //注册按钮
    UIButton* regBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    regBtn.frame=CGRectMake(20, 111+statusBarHeight, 280, 40);
    [regBtn setTitle:NSLocalizedString(@"registeruser", nil) forState:UIControlStateNormal];
    [regBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [regBtn addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [regBtn setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    
    //通讯录好友列表
    UIButton* friendsBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    friendsBtn.frame=CGRectMake(20, 170+statusBarHeight, 280, 40);
    [friendsBtn setTitle:NSLocalizedString(@"addressbookfriends", nil) forState:UIControlStateNormal];
    [friendsBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [friendsBtn addTarget:self action:@selector(getAddressBookFriends) forControlEvents:UIControlEventTouchUpInside];
    [friendsBtn setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    
    //导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0+statusBarHeight, 320, 44)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    [navigationItem setTitle:@"ShareSDK"];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    SMS_HYZBadgeView* testView=[[SMS_HYZBadgeView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _testView=testView;
    [testView setNumber:0];
    
    [friendsBtn addSubview:testView];
    
    _friendsBlock=^(enum SMS_ResponseState state,int latelyFriendsCount)
    {
        if (1==state)
        {
            NSLog(@"block 新好友数目重新设置");
            int count=latelyFriendsCount;
            [testView setNumber:count];
        }
    };
    
    [SMS_SDK showFriendsBadge:_friendsBlock];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //把导航栏添加到视图中
    [self.view addSubview:navigationBar];
    [self.view addSubview:regBtn];
    [self.view addSubview:friendsBtn];
}

-(void)registerUser
{
    RegViewController* reg=[[RegViewController alloc] init];
    [self presentViewController:reg animated:YES completion:^{
        
    }];
}

-(void)getAddressBookFriends
{
    [_testView setNumber:0];
    
    SectionsViewControllerFriends* friends=[[SectionsViewControllerFriends alloc] init];
    _friendsController=friends;
    [_friendsController setMyBlock:_friendsBlock];
    [SMS_MBProgressHUD showMessag:NSLocalizedString(@"loading", nil) toView:self.view];
    [SMS_SDK getAppContactFriends:1 result:^(enum SMS_ResponseState state, NSArray *array) {
        if (1==state)
        {
            NSLog(@"block 获取好友列表成功");
            
            [_friendsController setMyData:[NSMutableArray arrayWithArray:array]];
            [self presentViewController:_friendsController animated:YES completion:^{
                            ;
                        }];
                }
        else if(0==state)
        {
            NSLog(@"block 获取好友列表失败");
        }

    }];
    
    //判断用户通讯录是否授权
    if (_alert1)
    {
        [_alert1 show];
    }
    
    if(ABAddressBookGetAuthorizationStatus()!=kABAuthorizationStatusAuthorized&&_alert1==nil)
    {
        NSString* str=[NSString stringWithFormat:NSLocalizedString(@"authorizedcontact", nil)];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
        _alert1=alert;
        [alert show];
    }

    
}



@end
