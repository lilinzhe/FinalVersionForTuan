#import "UIView+Extension.h"
#import "MJExtension.h"
#import <Foundation/Foundation.h>


#ifdef DEBUG
#define MTLog(...) NSLog(__VA_ARGS__)
#else
#define MTLog(...)
#endif

#define MTColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define MTGlobalBg MTColor(230, 230, 230)

#define RequestURL @"v1/deal/find_deals"

extern NSString *const CityDidChangeNotification;
extern NSString *const SelectCityName;

extern NSString *const SortDidChangeNotification;
extern NSString *const SelectSort;

extern NSString *const CategoryDidChangeNotification;
extern NSString *const Selectcategory;
extern NSString *const SelectsubCategory;

extern NSString *const regionDidChangeNotification;
extern NSString *const SelectRegion;
extern NSString *const SelectsubRegion;

extern NSString *const DealCheckingChangeNotification;
