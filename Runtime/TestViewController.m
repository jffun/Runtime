//
//  TestViewController.m
//  Runtime
//
//  Created by yulm on 16/4/21.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    btn.frame = CGRectMake(200, 200, 50, 50);
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)tap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
