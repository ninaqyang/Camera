//
//  UINavigationBar+CustomNav.m
//  Camera App
//
//  Created by Nina Yang on 11/9/15.
//  Copyright © 2015 Nina Yang. All rights reserved.
//

#import "UINavigationBar+CustomNav.h"

@implementation UINavigationBar (CustomNav)

+ (instancetype)customizeNavigationBar:(UINavigationBar *)navBar {
    navBar.barStyle = UIBarStyleBlack;
    
    [navBar setBarTintColor:[UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1.0]];
    
    return navBar;
}

//- (void)createNavBarButtonItem:(UIBarButtonItem *)barButtonItem withImage:(UIImage *)image selector:(NSString *)selector {
//    
//    barButtonItem = [[UIBarButtonItem alloc] initWithImage:image landscapeImagePhone:image style:UIBarButtonItemStylePlain target:self action:@selector(selector)];
//}

@end
