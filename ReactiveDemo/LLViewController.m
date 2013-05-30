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
#import <AFNetworking/AFNetworking.h>

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
    RACSignal * orientationSignal = [orientationSubject startWith:@(self.interfaceOrientation)];
    
    RACSignal * orientationImageSignal = [orientationSignal map:^id(NSNumber * interfaceOrientationNumber) {
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)[interfaceOrientationNumber integerValue];
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
            return [UIImage imageNamed:@"longcat.jpg"];
        } else {
            return [UIImage imageNamed:@"serious_cat.jpg"];
        }
    }];
    
    RACSignal * buttonPressedSignal = [[self.button
        rac_signalForControlEvents:UIControlEventTouchUpInside]
        mapReplace:[UIImage imageNamed:@"wat_cat.gif"]];

    RACSignal * combinedSignal = [RACSignal merge:@[orientationImageSignal, buttonPressedSignal]];
    
    RACSignal * applicationActiveSignal = [[RACSignal
        merge:@[
            [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] mapReplace:[UIImage imageNamed:@"grumpy_cat.jpg"]],
            [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] mapReplace:nil]
        ]]
        startWith:nil];
    
    RACSignal * caturdaySignal = [[[[self class]
        resubscribingSignal:[[self class] canHasCaturdayFake] withDelay:5]
        map:^id(NSNumber * canHas) {
            return [canHas boolValue] ? [UIImage imageNamed:@"ninja_cat.jpg"] : nil;
        }]
        startWith:nil];
    
    combinedSignal = [RACSignal combineLatest:@[combinedSignal, applicationActiveSignal, caturdaySignal] reduce:^id(UIImage * combinedImage, UIImage * applicationActiveImage, UIImage * caturdayImage){
        UIImage * image = caturdayImage ?: (applicationActiveImage ?: combinedImage);
        return image;
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

+ (RACSignal *) canHasCaturday
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL * url = [NSURL URLWithString:@"http://www.abevigoda.com"];
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url];
        
        AFJSONRequestOperation * request = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSNumber * canHas = JSON[@"canHas"];
            
            [subscriber sendNext:canHas];
            [subscriber sendCompleted];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            
            [subscriber sendError:error];
            
        }];
        [request start];
        
        return [RACDisposable disposableWithBlock:^{
            request.completionBlock = ^{};
            [request cancel];
        }];
    }];
}

+ (RACSignal *) canHasCaturdayFake
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        u_int32_t random = arc4random_uniform(2);
        BOOL canHas = (random == 0) ? YES : NO;
        [subscriber sendNext:@(canHas)];
        [subscriber sendCompleted];
        return nil;
    }];
}

+ (RACSignal *) resubscribingSignal:(RACSignal *)signal withDelay:(NSTimeInterval)timeInterval
{
    return [[[[RACSignal
        interval:timeInterval]
        mapReplace:signal]
        switchToLatest]
        deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
