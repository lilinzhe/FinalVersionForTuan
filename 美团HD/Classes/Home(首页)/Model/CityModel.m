//
//  City.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "CityModel.h"
#import "MJExtension.h"
#import "RegionModel.h"

@implementation CityModel

-(NSDictionary *)objectClassInArray{
    return @{@"regions" : [RegionModel class]};
}

@end
