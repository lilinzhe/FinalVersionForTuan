//
//  DealTool.h
//  美团HD
//
//  Created by  tarena on 15/6/5.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DealModel;

@interface DealTool : NSObject

+(instancetype)shardDealTool;

/**
 *  返回第page页的收藏团购数据:page从1开始
 */
- (NSArray *)collectDeals:(int)page;
/**
 *  返回第page页的收藏团购数据:page从1开始
 */
- (int)collectDealsCount;
/**
 *  收藏一个团购
 */
- (void)addCollectDeal:(DealModel *)deal;
/**
 *  取消收藏一个团购
 */
- (void)removeCollectDeal:(DealModel *)deal;
/**
 *  团购是否收藏
 */
- (BOOL)isCollected:(DealModel *)deal;



@end
