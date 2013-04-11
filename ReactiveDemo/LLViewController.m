//
//  LLViewController.m
//  ReactiveDemo
//
//  Created by Lawrence Lomax on 7/04/13.
//  Copyright (c) 2013 Lawrence Lomax. All rights reserved.
//

#import "LLViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self)
    RACSignal * orientationImageSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [subscriber sendNext:@(self.interfaceOrientation)];
        
        return [orientationSubject subscribeNext:^(id x) {
            [subscriber sendNext:x];
        }];
    }];
    
    orientationImageSignal = [orientationImageSignal map:^id(NSNumber * interfaceOrientationNumber) {
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[interfaceOrientationNumber integerValue];
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
            return [UIImage imageNamed:@"longcat.jpg"];
        } else {
            return [UIImage imageNamed:@"serious_cat.jpg"];
        }
    }];
    
    RAC(self.imageView.image) = orientationImageSignal;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [orientationSubject sendNext:@(self.interfaceOrientation)];
}

@end
