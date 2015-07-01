//
//  DealAnnotation.h
//  美团HD
//
//  Created by   on 15/6/7.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DealAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
/** 图片名 */
@property (nonatomic, copy) NSString *icon;

@end
