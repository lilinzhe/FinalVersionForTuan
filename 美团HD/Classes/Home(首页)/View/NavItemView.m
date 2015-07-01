//
//  NavItemView.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "NavItemView.h"

@interface NavItemView ()

@property (weak, nonatomic) IBOutlet UIButton *itemButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLable;

@end


@implementation NavItemView

-(void)setTitle:(NSString *)title{
    _title=title;
    self.titleLable.text=title;
}

-(void)setSubtitle:(NSString *)subtitle{
    _subtitle=subtitle;
    self.subTitleLable.text=subtitle;
}

-(void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon{
    [self.itemButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [self.itemButton setImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
}

+(instancetype)item{
    return [[[NSBundle mainBundle]loadNibNamed:@"NavItemView" owner:nil options:nil]lastObject];
}

-(void)addTarget:(id)target action:(SEL)action{
    [self.itemButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)awakeFromNib{
    self.autoresizingMask=UIViewAutoresizingNone;
}

@end
