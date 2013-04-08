//
//  LLViewController.m
//  ReactiveDemo
//
//  Created by Lawrence Lomax on 7/04/13.
//  Copyright (c) 2013 Lawrence Lomax. All rights reserved.
//

#import "LLViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LLViewController ()

@end

@implementation LLViewController

- (void)loadView
{
    [super loadView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.view.bounds, 40, 40)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.imageView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}



@end
