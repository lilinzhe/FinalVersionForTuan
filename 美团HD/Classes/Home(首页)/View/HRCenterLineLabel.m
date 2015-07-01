//
//  HRCenterLineLabel.m
//  美团HD
//
//  Created by  tarena on 15/6/4.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "HRCenterLineLabel.h"

@implementation HRCenterLineLabel

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIBezierPath *path=[UIBezierPath bezierPathWithRect:CGRectMake(0, rect.size.height/2-0.5, rect.size.width, 1)];
    [path fill];
}

@end
