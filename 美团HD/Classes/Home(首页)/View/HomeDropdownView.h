
//首页导航栏下拉菜单

#import <UIKit/UIKit.h>
#import "HomeDropdownModel.h"


@interface HomeDropdownView : UIView

+(instancetype)dropdownView;

@property(nonatomic,strong)NSArray *homeDropdownModels;

@end



@protocol HomeDropdownViewDelegate <NSObject>

-(void)homeDropdownModel:(HomeDropdownModel *)homeDropdownModel SubTitle:(NSString *)subTitle;

@end

@interface HomeDropdownView()

@property(nonatomic,weak)id<HomeDropdownViewDelegate> delegate;

@end