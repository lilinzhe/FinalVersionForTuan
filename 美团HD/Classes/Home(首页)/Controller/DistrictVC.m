//
//  DistrictVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "DistrictVC.h"
#import "HomeDropdownView.h"
#import "MTConst.h"
#import "ChooseCityVC.h"
#import "NaviC.h"
#import "MetadataModel.h"

@interface DistrictVC ()<HomeDropdownViewDelegate>

//下拉菜单
@property(strong,nonatomic)HomeDropdownView *dropdownV;

@end

@implementation DistrictVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置popvoe推出时，显示的大小
    self.preferredContentSize=self.dropdownV.size;
    
    //监听城市改变的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cityChange:) name:CityDidChangeNotification object:nil];
    
}

//懒加载
-(HomeDropdownView *)dropdownV{
    if (_dropdownV==nil) {
        //创建下拉菜单
        UIView *view=[self.view.subviews firstObject];
        _dropdownV=[HomeDropdownView dropdownView];
        _dropdownV.y=view.height;
        _dropdownV.delegate=self;
        [self.view addSubview:_dropdownV];
    }
    return _dropdownV;
}

//利用set方法更新下拉菜单
-(void)setRegions:(NSArray *)regions{
    for (RegionModel *region in regions) {
        region.title=region.name;
        region.subTitles=region.subregions;
    }
    _regions=regions;
    self.dropdownV.homeDropdownModels=_regions;
}

//切换城市按钮点击事件
- (IBAction)clickChangeCity:(id)sender {
    
    ChooseCityVC *chooseCity=[[ChooseCityVC alloc]initWithNibName:@"ChooseCityVC" bundle:nil];
    NaviC *naviC=[[NaviC alloc] initWithRootViewController:chooseCity];
    naviC.modalPresentationStyle=UIModalPresentationFormSheet;
    [self presentViewController:naviC animated:YES completion:nil];
    
}

//接收到的通知
-(void)cityChange:(NSNotification *)noti{
    
    NSString *cityName=noti.userInfo[SelectCityName];    

    CityModel *city = [[[MetadataModel shared].citiesModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", cityName]] firstObject];
    self.regions = city.regions;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HomeDropdownViewDelegate
//发出通知
-(void)homeDropdownModel:(HomeDropdownModel *)homeDropdownModel SubTitle:(NSString *)subTitle{
    [[NSNotificationCenter defaultCenter] postNotificationName:regionDidChangeNotification object:nil userInfo:@{SelectRegion:(RegionModel *)homeDropdownModel,SelectsubRegion:subTitle}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
