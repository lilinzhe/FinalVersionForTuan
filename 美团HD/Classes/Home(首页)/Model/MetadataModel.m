//
//  MetadataModel.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "MetadataModel.h"
#import "MTConst.h"


@implementation MetadataModel

-(NSArray *)categoryModels{
    if (_categoryModels==nil) {
        _categoryModels=[CategoryModel objectArrayWithFilename:@"categories.plist"];
    }
    return _categoryModels;
}

-(NSArray *)citiesModels{
    if (_citiesModels==nil) {
        _citiesModels=[CityModel objectArrayWithFilename:@"cities.plist"];
    }
    return _citiesModels;
}

-(NSArray *)sortsModels{
    if (_sortsModels==nil) {
        _sortsModels=[SortModel objectArrayWithFilename:@"sorts.plist"];
    }
    return _sortsModels;
}

-(NSArray *)cityGroupsModels{
    if (_cityGroupsModels==nil) {
        _cityGroupsModels=[CityGroupModel objectArrayWithFilename:@"cityGroups.plist"];
    }
    return _cityGroupsModels;
}

+(instancetype)shared{
    static MetadataModel *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj=[[self alloc]init];
    });
    return obj;
}

-(CategoryModel *)categoryWithDeal:(DealModel *)deal{
    NSString *categoryName = [deal.categories firstObject];
    
    for (CategoryModel *category in self.categoryModels) {        
        if ([categoryName isEqualToString:category.name]) return category;
        if ([category.subcategories containsObject:categoryName]) return category;
    }
    return nil;
}

@end
