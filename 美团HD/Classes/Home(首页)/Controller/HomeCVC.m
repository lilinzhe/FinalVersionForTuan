//
//  HomeCVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "HomeCVC.h"
#import "UIBarButtonItem+Extension.h"
#import "NavItemView.h"
#import "CategoryVC.h"
#import "DistrictVC.h"
#import "MetadataModel.h"
#import "SortVC.h"
#import "MTConst.h"
#import "SearchCVC.h"
#import "NaviC.h"
#import "MJRefresh.h"
#import "AwesomeMenu.h"
#import "UIView+AutoLayout.h"
#import "CollectCVC.h"
#import "RecentCVC.h"
#import "MapVC.h"


@interface HomeCVC ()<AwesomeMenuDelegate>

//当前的属性
@property (nonatomic, copy) NSString *selectedCityName;
@property(nonatomic,copy)NSString *selectedCategory;
@property(nonatomic,copy)NSString *selectedRegion;
@property(nonatomic,strong)NSNumber *selectedSort;

@end

@implementation HomeCVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //设置默认数据
    self.selectedCityName=@"北京";
    self.selectedCategory=@"全部分类";
    self.selectedRegion=@"全部";
    self.selectedSort=@1;
    
    //设置导航栏的内容
    [self setupLeftNav];
    [self setupRightNav];
    
    //Menu的菜单
    [self setupMenu];
}

-(NSDictionary *)setParams{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    // 城市
    params[@"city"] = self.selectedCityName;    
    // 分类(类别)
    if (![self.selectedCategory isEqualToString:@"全部分类"]) {
        params[@"category"] = self.selectedCategory;
    }
    // 区域
    if (![self.selectedRegion isEqualToString:@"全部"]) {
        params[@"region"] = self.selectedRegion;
    }
    // 排序
    params[@"sort"]=self.selectedSort;
    
    return params;
}

#pragma mark - AwesomeMenuDelegate

-(void)setupMenu{
    
    // 1.中间的item
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:nil];
    
    // 2.周边的item
    AwesomeMenuItem *item0 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_highlighted"]];
    AwesomeMenuItem *item1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    AwesomeMenuItem *item2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    AwesomeMenuItem *item3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg_pathMenu_black_normal"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    NSArray *items = @[item0, item1, item2, item3];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem optionMenus:items];
    menu.alpha = 0.5;
    // 设置菜单的活动范围
    menu.menuWholeAngle = M_PI_2;
    // 设置开始按钮的位置
    menu.startPoint = CGPointMake(50, 150);
    // 设置代理
    menu.delegate = self;
    // 不要旋转中间按钮
    menu.rotateAddButton = NO;
    [self.view addSubview:menu];
    
    // 设置菜单永远在左下角
    [menu autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [menu autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [menu autoSetDimensionsToSize:CGSizeMake(200, 200)];
    
    
    [self.view addSubview:menu];
    
}

- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    
    // 完全显示
    menu.alpha = 1.0;
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    
    // 半透明显示
    menu.alpha = 0.5;
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    // 替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    
    switch (idx) {
        case 1: { // 收藏
            NaviC *nav = [[NaviC alloc] initWithRootViewController:[[CollectCVC alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
            
        case 2: { // 最近访问记录
            NaviC *nav = [[NaviC alloc] initWithRootViewController:[[RecentCVC alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - 设置导航栏

//设置右边按钮
-(void)setupRightNav{
    UIBarButtonItem *mapItem=[UIBarButtonItem itemWithTarget:self action:@selector(clickMap) image:@"icon_map" highImage:@"icon_map_highlighted"];
    mapItem.customView.width=60;
    
    UIBarButtonItem *searchItem=[UIBarButtonItem itemWithTarget:self action:@selector(searchClick) image:@"icon_search" highImage:@"icon_search_highlighted"];
    mapItem.customView.width=60;
    
    self.navigationItem.rightBarButtonItems=@[mapItem,searchItem];
    
}

//设置左边按钮
-(void)setupLeftNav{
    
    NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
    
    //logo
    UIBarButtonItem *logoItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStyleDone target:nil action:nil];    
    logoItem.enabled=NO;
    
    //分类
    NavItemView *categoryItemView=[NavItemView item];
    categoryItemView.title=@"全部分类";
    categoryItemView.subtitle=@"全部";
    [categoryItemView setIcon:@"icon_category_-1" highIcon:@"icon_category_highlighted_-1"];
    [categoryItemView addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem=[[UIBarButtonItem alloc]initWithCustomView:categoryItemView];

    //地区
    NavItemView *districtItemView=[NavItemView item];
    districtItemView.title=@"北京 - 全部";
    districtItemView.subtitle=@"全部";
    [districtItemView setIcon:@"icon_district" highIcon:@"icon_map_highlighted"];
    [districtItemView addTarget:self action:@selector(districtClick)];
    UIBarButtonItem *districtItem=[[UIBarButtonItem alloc]initWithCustomView:districtItemView];

    //排序
    NavItemView *sortItemView=[NavItemView item];
    sortItemView.title=@"排序";
    sortItemView.subtitle=@"默认排序";
    [sortItemView addTarget:self action:@selector(sortClick)];
    UIBarButtonItem *sortItem=[[UIBarButtonItem alloc]initWithCustomView:sortItemView];
    
    //设置导航栏左边按钮
    self.navigationItem.leftBarButtonItems=@[logoItem,categoryItem,districtItem,sortItem];
    
    //监听切换分类的通知
    [notiCenter addObserver:self selector:@selector(categoryChange:) name:CategoryDidChangeNotification object:nil];
    //监听切换城市的通知
    [notiCenter addObserver:self selector:@selector(cityChange:) name:CityDidChangeNotification object:nil];
    //监听切换区域的通知
    [notiCenter addObserver:self selector:@selector(regionChange:) name:regionDidChangeNotification object:nil];
    //监听切换排序的通知
    [notiCenter addObserver:self selector:@selector(sortChange:) name:SortDidChangeNotification object:nil];
}

//监听通知，更改item的显示信息，更新数据
-(void)categoryChange:(NSNotification *)noti{
    
    //取出当前分类数据
    CategoryModel *caregory=noti.userInfo[Selectcategory];
    
    //更改item的现实信息
    NavItemView *item=(NavItemView *)[self.navigationItem.leftBarButtonItems[1] customView];
    item.title=caregory.name;
    item.subtitle=noti.userInfo[SelectsubCategory];
    [item setIcon:caregory.icon highIcon:caregory.highlighted_icon];
    
    //更改选中的类别
    if ([item.subtitle isEqualToString:@"全部"]) {
        self.selectedCategory=caregory.name;
    }else{
        self.selectedCategory=item.subtitle;
    }

    //开始下拉刷新
    [self.collectionView headerBeginRefreshing];
    
}

-(void)cityChange:(NSNotification *)noti{
    
    //更改item的现实信息
    NavItemView *item=(NavItemView *)[self.navigationItem.leftBarButtonItems[2] customView];
    self.selectedCityName=noti.userInfo[SelectCityName];
    item.title=[self.selectedCityName stringByAppendingString:@" - 全部"];
    item.subtitle=nil;

    //初始化信息
    self.selectedRegion=@"全部";
    self.selectedCategory=@"全部分类";
    
    //开始下拉刷新
    [self.collectionView headerBeginRefreshing];
}

-(void)regionChange:(NSNotification *)noti{
    
    //取出当前区域数据
    RegionModel *region=noti.userInfo[SelectRegion];
    
    //更改item的现实信息
    NavItemView *item=(NavItemView *)[self.navigationItem.leftBarButtonItems[2] customView];
    item.title=[NSString stringWithFormat:@"%@ - %@",self.selectedCityName,region.name];
    item.subtitle=noti.userInfo[SelectsubRegion];;
    
    //更改选中的区域
    if ([item.subtitle isEqualToString:@"全部"]) {
        self.selectedRegion=region.name;
    }else{
        self.selectedRegion=item.subtitle;
    }

    //开始下拉刷新
    [self.collectionView headerBeginRefreshing];
}

-(void)sortChange:(NSNotification *)noti{
    //获取当前排序
    SortModel *sort=noti.userInfo[SelectSort];
    //更改item的现实信息
    NavItemView *item=(NavItemView *)[self.navigationItem.leftBarButtonItems[3] customView];
    item.subtitle=sort.label;
    //更改当前排序
    self.selectedSort=sort.value;
    //开始下拉刷新
    [self.collectionView headerBeginRefreshing];
}

//分类按钮点击事件
-(void)categoryClick{
    //创建
    UIPopoverController *popC=[[UIPopoverController alloc]initWithContentViewController:[[CategoryVC alloc]init]];
    //弹出popover
    [popC presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItems[1] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//城市按钮点击事件
-(void)districtClick{
    
    DistrictVC *districtVC=[[DistrictVC alloc]init];
    
    if (self.selectedCityName) {
        // 获得当前选中城市
        CityModel *city = [[[MetadataModel shared].citiesModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.selectedCityName]] firstObject];
        districtVC.regions = city.regions;
    }
    
    UIPopoverController *popC=[[UIPopoverController alloc]initWithContentViewController:districtVC];
    [popC presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItems[2] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//排序按钮点击事件
-(void)sortClick{
    UIPopoverController *popC=[[UIPopoverController alloc]initWithContentViewController:[[SortVC alloc]init]];
    [popC presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItems[3] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//搜索按钮的点击事件
-(void)searchClick{
    NaviC *navi=[[NaviC alloc]initWithRootViewController:[[SearchCVC alloc]init]];
    
    //保存选中城市到沙河
    NSUserDefaults *userDeaults=[NSUserDefaults standardUserDefaults];
    [userDeaults setObject:self.selectedCityName forKey:@"city"];
    [userDeaults synchronize];
    
    [self presentViewController:navi animated:YES completion:nil];
}

//地图按钮点击事件
-(void)clickMap{
    
    NaviC *navi=[[NaviC alloc]initWithRootViewController:[[MapVC alloc]initWithNibName:@"MapVC" bundle:nil]];
    
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark 其他

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
