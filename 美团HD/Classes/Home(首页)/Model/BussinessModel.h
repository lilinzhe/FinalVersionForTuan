//
//  BussinessModel.h
//  美团HD
//
//  Created by  tarena on 15/6/6.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BussinessModel : NSObject

/** 店名 */
@property (nonatomic, copy) NSString *name;
/** 纬度 */
@property (nonatomic, assign) float latitude;
/** 经度 */
@property (nonatomic, assign) float longitude;

@end
