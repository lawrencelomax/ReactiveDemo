//
//  LLViewController.m
//  ReactiveDemo
//
//  Created by Lawrence Lomax on 7/04/13.
//  Copyright (c) 2013 Lawrence Lomax. All rights reserved.
//

#import "LLViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSNotificationCenter+RACSupport.h"
#import <libextobjc/EXTScope.h>

@interface LLViewController ()

@end

@implementation LLViewController
{
    RACSubject * orientationSubject;
}

- (void)loadView
{
    [super loadView];
    
    orientationSubject = [RACSubject subject];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.view.bounds, 40, 40)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.backgroundColor = [UIColor blueColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(CGRectGetMinX(self.imageView.frame),
                                   CGRectGetMaxY(self.imageView.frame),
                                   CGRectGetWidth(self.imageView.frame),
                                   40);
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.button setTitle:@"????????" forState:UIControlStateNormal];
    [self.view addSubview:self.button];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self)
    RACSignal * orientationSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [subscriber sendNext:@(self.interfaceOrientation)];
        
        return [orientationSubject subscribeNext:^(id x) {
            [subscriber sendNext:x];
        }];
    }];
    
    RACSignal * orientationImageSignal = [orientationSignal map:^id(NSNumber * interfaceOrientationNumber) {
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[interfaceOrientationNumber integerValue];
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
            return [UIImage imageNamed:@"longcat.jpg"];
        } else {
            return [UIImage imageNamed:@"serious_cat.jpg"];
        }
    }];
    
    RACSignal * buttonPressedSignal = [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] mapReplace:[UIImage imageNamed:@"wat_cat.gif"]];
    RACSignal * combinedSignal = [RACSignal merge:@[orientationImageSignal, buttonPressedSignal]];
    
    RACSignal * applicationActiveSignal = [RACSignal merge:@[
        [RACSignal return:nil],
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] mapReplace:[UIImage imageNamed:@"grumpy_cat.jpg"]],
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] mapReplace:nil]
    ]];
    
    combinedSignal = [RACSignal combineLatest:@[combinedSignal, applicationActiveSignal] reduce:^id(UIImage * combinedImage, UIImage * applicationActiveImage){
        return applicationActiveImage ?: combinedImage;
    }];
    
    RAC(self.imageView.image) = combinedSignal;
    
    RAC(self.button.enabled) = [orientationSignal map:^id(NSNumber * interfaceOrientationNumber) {
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[interfaceOrientationNumber integerValue];
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
            return @(NO);
        } else {
            return @(YES);
        }
    }];
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [orientationSubject sendNext:@(self.interfaceOrientation)];
}

@end
