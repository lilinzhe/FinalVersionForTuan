//
//  DealsCVC.m
//  美团HD
//
//  Created by tarena on .
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "DealsCVC.h"
#import "MJRefresh.h"
#import "DPAPI.h"
#import "DealCell.h"
#import "UIView+AutoLayout.h"
#import "MTConst.h"
#import "DealModel.h"
#import "MBProgressHUD+MJ.h"
#import "DetailVC.h"

@interface DealsCVC ()<DPRequestDelegate>

//数据源
@property(nonatomic,strong)NSMutableArray *dealModels;
//最后一个的网络请求
@property(nonatomic,strong)DPRequest *lastRequest;
@property(nonatomic,assign)NSInteger totalCount;

//搜索结果为0的时候返回
@property(nonatomic,strong)UIImageView *noDataView;

@property(assign,nonatomic)NSInteger currentPage;

@end

@implementation DealsCVC

static NSString * const reuseIdentifier = @"deal";

//初始化的时候，顺便指定布局
-(instancetype)init{
    
    //创建流式布局
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    
    layout.itemSize=CGSizeMake(305, 305);
    
    //添加布局
    return [self initWithCollectionViewLayout:layout];
    
}

-(NSMutableArray *)dealModels{
    if (_dealModels==nil) {
        _dealModels=[NSMutableArray array];
    }
    return _dealModels;
}

-(UIImageView *)noDataView{
    if (_noDataView==nil) {
        _noDataView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
        [self.view addSubview:_noDataView];
        [_noDataView autoCenterInSuperview];
    }
    return _noDataView;
}

-(NSDictionary *)setParams{
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置竖直方向的弹簧效果
    self.collectionView.alwaysBounceVertical=YES;
    
    //设置布局
    [self viewWillTransitionToSize:self.view.size withTransitionCoordinator:nil];
    
    //设置背景色
    self.collectionView.backgroundColor=MTGlobalBg;
    
    //注册单元格
    [self.collectionView registerNib:[UINib nibWithNibName:@"DealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    //添加上拉刷新
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    //添加下拉刷新
    [self.collectionView addHeaderWithTarget:self action:@selector(loadNewDeals)];
}

//屏幕旋转，控制器尺寸发生变化的时候回调
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    //根据屏幕的狂傲。判断横竖屏,通过横竖屏判断cell的列数
    int cols=size.width>size.height?3:2;
    
    //获取当前布局
    UICollectionViewFlowLayout *layout=(UICollectionViewFlowLayout *)self.collectionViewLayout;
    //计算间距
    CGFloat space=(size.width-layout.itemSize.width*cols)/(cols+1);
    //设置区域间距
    layout.sectionInset=UIEdgeInsetsMake(space, space, space, space);
    //设置行间距
    layout.minimumLineSpacing=space;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    //判断总数量是否等于数据源数量，是的话，不再加载新数据
    self.collectionView.footerHidden=self.dealModels.count==self.totalCount;
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dealModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    DealModel *deal=self.dealModels[indexPath.item];
    
    cell.deal=deal;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailVC *detailVC=[[DetailVC alloc]initWithNibName:@"DetailVC" bundle:nil];
    
    detailVC.deal=self.dealModels[indexPath.row];
    
    [self presentViewController:detailVC animated:YES completion:nil];
}

#pragma mark 向服务器请求数据

//加载新数据
-(void)loadNewDeals{
    self.currentPage=1;
    
    [self loadDeals];
}

//加载更多数据
-(void)loadMoreDeals{
    //设置页码
    self.currentPage++;
    [self loadDeals];
}

//向服务器请求数据
-(void)loadDeals{
    
    DPAPI *api=[[DPAPI alloc]init];
    
    NSDictionary *dict=[self setParams];
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithDictionary:dict];
    
    //页码
    params[@"page"] = @(self.currentPage);
    // 每页的条数
    params[@"limit"] = @20;
    
    MTLog(@"请求数据用字典：%@",params);
    
    self.lastRequest=[api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    
    //如果返回的不是最后一个网络请求，就无视
    if (self.lastRequest!=request) {
        return;
    }
    
    //结束上拉加载
    [self.collectionView footerEndRefreshing];
    //结束下拉加载
    [self.collectionView headerEndRefreshing];
    //获取数据
    NSArray *deals=[DealModel objectArrayWithKeyValuesArray:result[@"deals"]];
    
    //如果是第一次添加，就清空数据源
    if (self.currentPage==1) {
        [self.dealModels removeAllObjects];
    }
    
    //添加数据进数组
    [self.dealModels addObjectsFromArray:deals];
    
    //保存搜索结果总数量
    self.totalCount=[result[@"total_count"] intValue];
    
    //判断数据源数量，如果为0就显示没有搜索结果
    self.noDataView.hidden=self.dealModels.count;
    
    //刷新表格
    [self.collectionView reloadData];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    //如果返回的不是最后一个网络请求，就无视
    if (self.lastRequest!=request) {
        return;
    }
    
    self.currentPage>1?(self.currentPage--):1;
    //显示提醒
    [MBProgressHUD showError:@"网络繁忙，请稍后再试" toView:self.view];
    
    if (error.code==10011) {
        NSLog(@"%@",@"分类错误");
    }    
    
    //结束上拉加载
    [self.collectionView footerEndRefreshing];
    //结束下拉加载
    [self.collectionView headerEndRefreshing];
}
@end
