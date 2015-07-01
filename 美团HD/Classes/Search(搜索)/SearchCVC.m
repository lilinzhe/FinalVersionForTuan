//
//  SearchCVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "SearchCVC.h"
#import "UIBarButtonItem+Extension.h"
#import "MTConst.h"
#import "MJRefresh.h"

@interface SearchCVC ()<UISearchBarDelegate>

@end

@implementation SearchCVC

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置左边的按钮
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted" ];
    
    //设置中间的搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"请输入关键词";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;

}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSDictionary *)setParams{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    params[@"city"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"city"];
    UISearchBar *bar = (UISearchBar *)self.navigationItem.titleView;
    params[@"keyword"] = bar.text;
    return params;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.collectionView headerBeginRefreshing];
    //清空搜索框
    searchBar.text=nil;
    // 退出键盘
    [searchBar resignFirstResponder];
}


@end
