//
//  DealTool.m
//  美团HD
//
//  Created by  tarena on 15/6/5.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "DealTool.h"
#import "FMDB.h"
#import "DealModel.h"

@interface DealTool ()

@property(nonatomic,strong)FMDatabase *database;

@end

@implementation DealTool

+(instancetype)shardDealTool{
    static DealTool *dealTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dealTool=[[DealTool alloc]init];
        
        // 1.打开数据库
        NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"deal.sqlite"];
        dealTool.database = [FMDatabase databaseWithPath:file];
        if (![dealTool.database open]) return;
        
        // 2.创表
        [dealTool.database executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collect_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL);"];
        [dealTool.database executeUpdate:@"CREATE TABLE IF NOT EXISTS t_recent_deal(id integer PRIMARY KEY, deal blob NOT NULL, deal_id text NOT NULL);"];
        
    });
    return dealTool;
}

/**
 *  返回第page页的收藏团购数据:page从1开始
 */
- (NSArray *)collectDeals:(int)page{
    int size = 20;
    int pos = (page - 1) * size;
    FMResultSet *set = [self.database executeQueryWithFormat:@"SELECT * FROM t_collect_deal ORDER BY id DESC LIMIT %d,%d;", pos, size];
    NSMutableArray *deals=[NSMutableArray array];
    while (set.next) {
        DealModel *deal = [NSKeyedUnarchiver unarchiveObjectWithData:[set objectForColumnName:@"deal"]];
        [deals addObject:deal];
    }
    return deals;
    
}

/**
 *  返回第page页的收藏团购数据:page从1开始
 */
- (int)collectDealsCount{
    FMResultSet *set = [self.database executeQueryWithFormat:@"SELECT count(*) AS deal_count FROM t_collect_deal;"];
    [set next];
    return [set intForColumn:@"deal_count"];
}
/**
 *  收藏一个团购
 */
- (void)addCollectDeal:(DealModel *)deal{
    
    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:deal];
    [self.database executeUpdateWithFormat:@"INSERT INTO t_collect_deal(deal, deal_id) VALUES(%@, %@);",data,deal.deal_id];
    
}
/**
 *  取消收藏一个团购
 */
- (void)removeCollectDeal:(DealModel *)deal{
    [self.database executeUpdateWithFormat:@"DELETE FROM t_collect_deal WHERE deal_id = %@;", deal.deal_id];
}
/**
 *  团购是否收藏
 */
- (BOOL)isCollected:(DealModel *)deal{
    FMResultSet *set = [self.database executeQueryWithFormat:@"SELECT count(*) AS deal_count FROM t_collect_deal WHERE deal_id = %@;", deal.deal_id];
    [set next];   
    return [set intForColumn:@"deal_count"] == 1;
}

@end
