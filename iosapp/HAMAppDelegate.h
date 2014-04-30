//
//  HAMAppDelegate.h
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMDBManager.h"

@class HAMSettingsViewController;
@class HAMViewController;
@class HAMInitViewController;

@interface HAMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) HAMViewController *viewController;
@property (strong, nonatomic) HAMSettingsViewController *structureEditViewController;

-(void)turnToChildView;
-(void)turnToParentView;

@end
