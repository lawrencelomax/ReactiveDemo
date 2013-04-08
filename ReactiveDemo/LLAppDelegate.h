//
//  LLAppDelegate.h
//  ReactiveDemo
//
//  Created by Lawrence Lomax on 7/04/13.
//  Copyright (c) 2013 Lawrence Lomax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLViewController;

@interface LLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LLViewController *viewController;

@end
