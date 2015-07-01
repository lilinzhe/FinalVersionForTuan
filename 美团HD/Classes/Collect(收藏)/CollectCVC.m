//
//  CollectCVC.m
//  美团HD
//
//  Created by  tarena on 15/6/5.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "CollectCVC.h"
#import "MTConst.h"
#import "UIBarButtonItem+Extension.h"
#import "DealTool.h"
#import "DealModel.h"
#import "DealCell.h"
#import "MJRefresh.h"
#import "DetailVC.h"
#import "UIView+AutoLayout.h"
#import "MBProgressHUD+MJ.h"


@interface CollectCVC ()

@property(nonatomic,strong)NSMutableArray *dealModels;
@property(nonatomic,weak)DealTool *dealTool;
//搜索结果为0的时候返回
@property(nonatomic,strong)UIImageView *noDataView;
@property(assign,nonatomic)NSInteger currentPage;
@property(nonatomic,strong)UIBarButtonItem *backItem;
@property(nonatomic,strong)NSArray *editingItems;

@end

@implementation CollectCVC

static NSString * const reuseIdentifier = @"deal";

//初始化的时候，顺便指定布局
-(instancetype)init{
    
    //创建流式布局
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    
    layout.itemSize=CGSizeMake(305, 305);
    
    //添加布局
    return [self initWithCollectionViewLayout:layout];
}

-(UIBarButtonItem *)backItem{
    if (_backItem==nil) {
        _backItem=[UIBarButtonItem itemWithTarget:self action:@selector(ClickBack) image:@"icon_back" highImage:@"icon_back_highlighted" ];
    }
    return _backItem;
}

-(NSArray *)editingItems{
    if (_editingItems==nil) {
        
        UIBarButtonItem *selectAllItem=[[UIBarButtonItem alloc]initWithTitle:@"   全选   " style:UIBarButtonItemStyleDone target:self action:@selector(ClickSelectAll)];
        UIBarButtonItem *unSelectAllItem=[[UIBarButtonItem alloc]initWithTitle:@"  全不选  " style:UIBarButtonItemStyleDone target:self action:@selector(ClickUnSelectAll)];
        UIBarButtonItem *removeItem=[[UIBarButtonItem alloc]initWithTitle:@"   删除   " style:UIBarButtonItemStyleDone target:self action:@selector(ClickRemove)];
        removeItem.enabled=NO;
        
        _editingItems=@[selectAllItem,unSelectAllItem,removeItem];
    }
    return _editingItems;
}

-(UIImageView *)noDataView{
    if (_noDataView==nil) {
        _noDataView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_collects_empty"]];
        [self.view addSubview:_noDataView];
        [_noDataView autoCenterInSuperview];
    }
    return _noDataView;
}

-(NSMutableArray *)dealModels{
    if (_dealModels==nil) {
        _dealModels=[NSMutableArray array];
        NSArray *deals=[self.dealTool collectDeals:1];
        [_dealModels addObjectsFromArray:deals];
    }
    return _dealModels;
}

-(DealTool *)dealTool{
    if (_dealTool==nil) {
        _dealTool=[DealTool shardDealTool];
    }
    return _dealTool;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //基本设置
    self.collectionView.alwaysBounceVertical=YES;
    self.title=@"收藏的团购";
    self.collectionView.backgroundColor=MTGlobalBg;
    
    //注册单元格
    [self.collectionView registerNib:[UINib nibWithNibName:@"DealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    //添加上拉刷新
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreDeals)];
    
    //设置单元格间距
    [self viewWillTransitionToSize:self.view.frame.size withTransitionCoordinator:nil];
    
    //设置导航栏左边的按钮
    self.navigationItem.leftBarButtonItems=@[self.backItem];
    
    //设置导航栏右边的按钮
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(ClickEditing:)];
    
    //注册状态改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkingState) name:DealCheckingChangeNotification object:nil];
}

//监听状态改变的通知
-(void)checkingState{
    BOOL state=NO;
    for (DealModel *deal in self.dealModels) {
        if (deal.checking) {
            state=YES;
        }
    }
    UIBarButtonItem *removeItem=self.editingItems[2];
    removeItem.enabled=state;
    
}

//点击返回
-(void)ClickBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//点击编辑
-(void)ClickEditing:(UIBarButtonItem *)item{
    if ([item.title isEqualToString:@"编辑"]) {
        item.title=@"完成";
        self.navigationItem.leftBarButtonItems=@[self.backItem,self.editingItems[0],self.editingItems[1],self.editingItems[2]];
        
        for (DealModel *deal in self.dealModels) {
            deal.editing=YES;
            
        }
        
    }else{
        item.title=@"编辑";
        self.navigationItem.leftBarButtonItems=@[self.backItem];
        
        for (DealModel *deal in self.dealModels) {
            deal.editing=NO;
            deal.checking=NO;
        }
    }
    
    [self.collectionView reloadData];
}

//点击全选
-(void)ClickSelectAll{
    for (DealModel *deal in self.dealModels) {
        deal.checking=YES;
    }
    
    [self.collectionView reloadData];
    UIBarButtonItem *tiem=self.editingItems[2];
    tiem.enabled = YES;
}

//点击取消全选
-(void)ClickUnSelectAll{
    for (DealModel *deal in self.dealModels) {
        deal.checking=NO;
    }
    
    [self.collectionView reloadData];
    
    UIBarButtonItem *tiem=self.editingItems[2];
    
    tiem.enabled = NO;
}

//点击删除
-(void)ClickRemove{
    
    NSMutableArray *marray=[NSMutableArray array];
    
    for (DealModel *deal in self.dealModels) {
        if (deal.checking==YES) {
            [self.dealTool removeCollectDeal:deal];
            [marray addObject:deal];
        }
    }
    for (DealModel *deal in marray) {
        [self.dealModels removeObject:deal];
    }
    
    [self.collectionView reloadData];
    
    UIBarButtonItem *removeItem=self.editingItems[2];
    removeItem.enabled=NO;
}

//加载更多数据
-(void)loadMoreDeals{
    //设置页码
    self.currentPage++;
    
    NSArray *deals=[self.dealTool collectDeals:(int)self.currentPage];
    
    if (deals.count<1) {
        [MBProgressHUD showError:@"没有更多收藏"];
        self.collectionView.footerHidden=YES;
    }else{
        [self.dealModels addObjectsFromArray:deals];
        [self.collectionView reloadData];
        [self.collectionView footerEndRefreshing];
    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //清空数据
    self.dealModels=nil;
    //页码变成1
    self.currentPage=1;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.collectionView reloadData];
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
    
    
    self.noDataView.hidden=self.dealModels.count;
    
    if ((self.dealModels.count==[self.dealTool collectDealsCount] )||self.dealModels.count<1) {
        self.collectionView.footerHidden=YES;
    }else{
        self.collectionView.footerHidden=NO;
    }
    
    
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
