//
//  ChooseCityVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "ChooseCityVC.h"
#import "UIBarButtonItem+Extension.h"
#import "MetadataModel.h"
#import "SearchResultTVC.h"
#import "UIView+AutoLayout.h"
#import "MTConst.h"

@interface ChooseCityVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

//数据
@property(nonatomic,strong)NSArray *cityGroups;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
//遮盖
@property (weak, nonatomic) IBOutlet UIButton *cover;
//搜索框
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//搜索结果显示表格
@property(strong,nonatomic)SearchResultTVC *searchResultTVC;

@end

@implementation ChooseCityVC

//懒加载
-(SearchResultTVC *)searchResultTVC{
    if (_searchResultTVC==nil) {
        _searchResultTVC=[[SearchResultTVC alloc]init];
        //添加搜索结果视图
        [self addChildViewController:_searchResultTVC];
        [self.view addSubview:self.searchResultTVC.view];
        
        //添加约束 除了上部，其他距离父视图都为0
        [self.searchResultTVC.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        //添加顶部约束 靠近搜索框底部10
        [self.searchResultTVC.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:10];
    }
    return _searchResultTVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //基本设置
    self.title=@"切换城市";
    self.tableV.sectionIndexColor=[UIColor blackColor];
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem itemWithTarget:self action:@selector(close) image:@"btn_navigation_close" highImage:@"btn_navigation_close_hl"];
    
    //加载城市数据
    self.cityGroups=[MetadataModel shared].cityGroupsModels;
    
    //设置样式
    self.searchBar.tintColor=[UIColor colorWithRed:32/255.0 green:191/255.0 blue:179/255.0 alpha:1.0];

}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickCover:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.cityGroups.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CityGroupModel *cityCroup=self.cityGroups[section];
    return cityCroup.cities.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    CityGroupModel *cityGroup=self.cityGroups[indexPath.section];
    
    cell.textLabel.text=cityGroup.cities[indexPath.row];
    return cell;
}

//设置表头
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.cityGroups[section] title];
}

//设置索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [self.cityGroups valueForKey:@"title"];
}

//点中表格的时候发出通知
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CityGroupModel *group=self.cityGroups[indexPath.section];
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:CityDidChangeNotification object:nil userInfo:@{SelectCityName:group.cities[indexPath.row]}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

//文本框开始编辑的时候回调
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
    //修改搜索框的背景图片
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield_hl"]];
    //显示取消按钮
    [searchBar setShowsCancelButton:YES animated:YES];
    //显示遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.cover.alpha=0.5;
    }];
    
}

//文本框结束编辑的时候回调
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    //显示导航栏
    [self.navigationController setNavigationBarHidden:NO];
    //修改搜索框的背景图片
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield"]];
    //隐藏取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    //隐藏遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.cover.alpha=0.0;
    }];
    //隐藏搜索视图
    self.searchResultTVC.view.hidden=YES;
    //清空搜索框的文字
    searchBar.text=nil;
}

//搜索框取消按钮点击事件
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

//搜索框里面的文字变化的时候调用
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length) {
        self.searchResultTVC.view.hidden=NO;
        self.searchResultTVC.searchText=searchText;
    }else{
        self.searchResultTVC.view.hidden=YES;
    }    
}




@end
