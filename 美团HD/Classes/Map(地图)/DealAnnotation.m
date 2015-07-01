//
//  DealAnnotation.m
//  美团HD
//
//  Created by  tarena on 15/6/7.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "DealAnnotation.h"

@implementation DealAnnotation

- (BOOL)isEqual:(DealAnnotation *)other
{
    return [self.title isEqual:other.title];
}

@end
