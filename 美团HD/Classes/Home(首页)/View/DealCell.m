//
//  MTDealCell.m
//  黑团HD
//
//  Created by apple on 14-8-19.
//  Copyright (c) 2014年  tarena. All rights reserved.
//

#import "DealCell.h"
#import "DealModel.h"
#import "UIImageView+WebCache.h"
#import "MTConst.h"

@interface DealCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView;

@property (weak, nonatomic) IBOutlet UIButton *cover;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;

@end

@implementation DealCell

- (void)setDeal:(DealModel *)deal
{
    _deal = deal;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.s_image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    self.listPriceLabel.text=[NSString stringWithFormat:@"¥ %@", deal.list_price];
    self.purchaseCountLabel.text=[NSString stringWithFormat:@"已售%@", deal.purchase_count];
    self.currentPriceLabel.text=[NSString stringWithFormat:@"¥ %@", deal.current_price];
    
    //获取小数点的位置
    NSInteger dotloc = [self.currentPriceLabel.text rangeOfString:@"."].location;
    //如果小数点的位置获取成功，就判断小数位，如果大于2位就取两位
    if (dotloc!=NSNotFound) {
        if (self.currentPriceLabel.text.length-dotloc>2) {
            self.currentPriceLabel.text=[self.currentPriceLabel.text substringToIndex:dotloc+3];
        }
    }
    
    //获取当前系统时间
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=@"yyyy-MM-dd";
    NSString *now=[formatter stringFromDate:[NSDate date]];
    
    //通过判断两个字符串的比较结果来判断大小
    self.dealNewView.hidden=([deal.publish_date compare:now]==NSOrderedAscending);
    
    // 根据模型属性来控制cover的显示和隐藏
    self.cover.hidden = !deal.isEditting;
    
    // 根据模型属性来控制打钩的显示和隐藏
    self.checkView.hidden = !deal.isChecking;
    

}
- (IBAction)coverClick:(id)sender {
    // 设置模型
    self.deal.checking = !self.deal.isChecking;
    // 直接修改状态
    self.checkView.hidden = !self.checkView.isHidden;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DealCheckingChangeNotification object:nil userInfo:nil];
    
}

- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"bg_dealcell"] drawInRect:rect];

}
@end
