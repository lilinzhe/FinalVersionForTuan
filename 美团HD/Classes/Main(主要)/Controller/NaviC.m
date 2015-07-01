//
//  MTNavigationController.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "NaviC.h"

@interface NaviC ()

@end

@implementation NaviC

+(void)initialize{
    UINavigationBar *bar= [UINavigationBar appearance];
    [bar setBackgroundImage:[UIImage imageNamed:@"bg_navigationBar_normal"] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *item=[UIBarButtonItem appearance];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:21/255.0 green:188/255.0 blue:173/255.0 alpha:1]} forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateDisabled];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



@end
