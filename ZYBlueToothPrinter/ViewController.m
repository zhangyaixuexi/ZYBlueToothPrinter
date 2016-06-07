//
//  ViewController.m
//  ZYBlueToothPrinter
//
//  Created by zhangyi on 16/4/6.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import "ViewController.h"
#import "ZYBlueToothViewController.h"
#import "BlueTooth.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button setTitle:@"打印" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToPrintVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)goToPrintVC
{
    BlueTooth * blueTooth = [BlueTooth shareBlueTooth];
    blueTooth.parentVC = self;
    [blueTooth printStringWithContent:@"好想好想你好想好想你好你好想好想你好想好想你好想好想你好想好想你好你好想好想你好想好你好想好想你好想好想好好想你好想好想好想好你好想好想"];
}
@end
