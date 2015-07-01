//
//  SortVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "SortVC.h"
#import "MetadataModel.h"
#import "MTConst.h"

@interface SortVC ()

@property(nonatomic,strong)NSArray *sortModels;

@end

@implementation SortVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat btnW = 100;
    CGFloat btnH = 30;
    CGFloat btnX = 15;
    CGFloat btnStartY = 15;
    CGFloat btnMargin = 15;
    CGFloat height = 0;
    
    for (NSUInteger i = 0; i<self.sortModels.count; i++) {
        SortModel *sort = self.sortModels[i];
        
        UIButton *button = [[UIButton alloc] init];
        button.width = btnW;
        button.height = btnH;
        button.x = btnX;
        button.y = btnStartY + i * (btnH + btnMargin);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitle:sort.label forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_filter_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_filter_selected"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.view addSubview:button];
        
        height = CGRectGetMaxY(button.frame);
    }
    
    // 设置控制器在popover中的尺寸
    CGFloat width = btnW + 2 * btnX;
    height += btnMargin;
    self.preferredContentSize = CGSizeMake(width, height);
}

- (void)buttonClick:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SortDidChangeNotification object:nil userInfo:@{SelectSort : self.sortModels[button.tag]}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSArray *)sortModels{
    if (_sortModels==nil) {
        _sortModels=[MetadataModel shared].sortsModels;
    }
    return _sortModels;
}

@end
