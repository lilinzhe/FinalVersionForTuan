//
//  DealModel.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "DealModel.h"
#import "MJExtension.h"
#import "BussinessModel.h"

@implementation DealModel

- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"desc" : @"description"};
}

- (NSDictionary *)objectClassInArray
{
    return @{@"businesses" : [BussinessModel class]};
}

MJCodingImplementation

@end
