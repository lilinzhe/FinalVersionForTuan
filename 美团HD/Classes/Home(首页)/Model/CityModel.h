
//城市模型

#import <Foundation/Foundation.h>

@interface CityModel : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *pinYin;
@property(nonatomic,copy)NSString *pinYinHead;
@property(nonatomic,strong)NSArray *regions;



@end
