//
//  AppDelegate.h
//  Camera App
//
//  Created by Nina Yang on 11/5/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) CameraViewController *photoVC;

@end

