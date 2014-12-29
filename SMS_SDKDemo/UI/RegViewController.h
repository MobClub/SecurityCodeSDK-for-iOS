//
//  RegViewController.h
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionsViewController.h"

@interface RegViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,SecondViewControllerDelegate,UITextFieldDelegate>

@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UITextField* areaCodeField;
@property(nonatomic,strong) UITextField* telField;
@property(nonatomic,strong) UIWindow* window;
@property(nonatomic,strong) UIButton* next;

-(void)nextStep;

@end
