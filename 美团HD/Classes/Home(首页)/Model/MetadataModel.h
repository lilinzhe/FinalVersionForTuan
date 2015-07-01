//
//  MetadataModel.h
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryModel.h"
#import "CityModel.h"
#import "RegionModel.h"
#import "CityGroupModel.h"
#import "SortModel.h"
#import "DealModel.h"

@interface MetadataModel : NSObject

@property(nonatomic,strong)NSArray *categoryModels;

@property(nonatomic,strong)NSArray *citiesModels;

@property(nonatomic,strong)NSArray *cityGroupsModels;

@property(nonatomic,strong)NSArray *sortsModels;

+(instancetype)shared;
-(CategoryModel *)categoryWithDeal:(DealModel *)deal;

@end
