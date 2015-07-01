
//首页导航栏按钮类

#import <UIKit/UIKit.h>

@interface NavItemView : UIView

@property(nonatomic,copy)NSString *title;

@property(nonatomic,copy)NSString *subtitle;

-(void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon;
          
          
+(instancetype)item;

-(void)addTarget:(id)target action:(SEL)action;

@end
