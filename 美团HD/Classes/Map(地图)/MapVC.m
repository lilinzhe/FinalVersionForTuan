//
//  MapVC.m
//  美团HD
//
//  Created by   on 15/6/6.
//  Copyright (c) 2015年 hare. All rights reserved.
//

#import "MapVC.h"
#import "UIBarButtonItem+Extension.h"
#import <MapKit/MapKit.h>
#import "DPAPI.h"
#import "NavItemView.h"
#import "CategoryVC.h"
#import "CategoryModel.h"
#import "MTConst.h"
#import "MBProgressHUD+MJ.h"
#import "BussinessModel.h"
#import "DealModel.h"
#import "DealAnnotation.h"
#import "MetadataModel.h"

@interface MapVC ()<MKMapViewDelegate,DPRequestDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapV;
@property(nonatomic,copy)NSString *selectedCategory;
@property(nonatomic,strong)CLGeocoder *geocoder;
@property(nonatomic,copy)NSString *selectedCityName;
@property(nonatomic,strong)DPRequest *lastRequest;

@end

@implementation MapVC

-(CLGeocoder *)geocoder{
    if (_geocoder==nil) {
        _geocoder=[[CLGeocoder alloc]init];
    }
    return _geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"地图";
    
    //返回按钮
    UIBarButtonItem *bactItem=[UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highImage:@"icon_back_highlighted" ];
    //分类
    NavItemView *categoryItemView=[NavItemView item];
    categoryItemView.title=@"全部分类";
    categoryItemView.subtitle=@"全部";
    [categoryItemView setIcon:@"icon_category_-1" highIcon:@"icon_category_highlighted_-1"];
    [categoryItemView addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem=[[UIBarButtonItem alloc]initWithCustomView:categoryItemView];
    
    // 监听分类改变
    //监听切换分类的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryChange:) name:CategoryDidChangeNotification object:nil];
    
    self.navigationItem.leftBarButtonItems=@[bactItem,categoryItem];
    
    //设置地图标记为跟随自己的位置变化
    self.mapV.userTrackingMode=MKUserTrackingModeFollow;
    //设置地图的样式
    self.mapV.mapType=MKMapTypeStandard;
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
    
    [self.mapV removeAnnotations:self.mapV.annotations];
    
    
    [self mapView:self.mapV regionDidChangeAnimated:YES];
}

//返回按钮点击事件
-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//分类按钮点击事件
-(void)categoryClick{
    //创建
    UIPopoverController *popC=[[UIPopoverController alloc]initWithContentViewController:[[CategoryVC alloc]init]];
    //弹出popover
    [popC presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItems[1] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//定位按钮点击事件
- (IBAction)clickLocationButton:(id)sender {
    
}

#pragma mark - MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    //根据一个location获得位置
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count==0) return;
        
        CLPlacemark *placemark=[placemarks firstObject];
        NSRange range=[placemark.locality rangeOfString:@"市"];
        
        if (range.location>=placemark.locality.length) {
            self.selectedCityName=placemark.locality;
        }else{
            self.selectedCityName=[placemark.locality substringToIndex:range.location];
        }

        [self mapView:mapView regionDidChangeAnimated:nil];
        
    }];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[DealAnnotation class]]) {
        MKAnnotationView *annoView=[mapView dequeueReusableAnnotationViewWithIdentifier:@"deal"];
        DealAnnotation *dealAnno=(DealAnnotation *)annotation;
        if (annoView==nil) {
            annoView=[[MKAnnotationView alloc]initWithAnnotation:nil reuseIdentifier:@"deal"];
            annoView.canShowCallout = YES;
        }
        
        annoView.annotation=dealAnno;
        annoView.image=[UIImage imageNamed:dealAnno.icon];
        
        return annoView;
    }else{
        return nil;
    }
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.selectedCityName == nil) return;
    
    // 发送请求给服务器
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 城市
    params[@"city"] = self.selectedCityName;
    // 类别
    if (self.selectedCategory&&(![self.selectedCategory isEqualToString:@"全部分类"])) {
        params[@"category"] = self.selectedCategory;
    }
    // 经纬度
    params[@"latitude"] = @(mapView.region.center.latitude);
    params[@"longitude"] = @(mapView.region.center.longitude);
    params[@"radius"] = @(5000);
    
    NSLog(@"请求用参数%@",params);
    
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error{
    
    if (request != self.lastRequest) return;
    
    [MBProgressHUD showError:@"本处无团购" toView:self.view];
    
    NSLog(@"请求失败 - %@", error);
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(NSDictionary *)result{
    
    if (request != self.lastRequest) return;
    
    NSArray *deals = [DealModel objectArrayWithKeyValuesArray:result[@"deals"]];
    for (DealModel *deal in deals) {
        
        
        for (BussinessModel *business in deal.businesses) {
            DealAnnotation *anno=[[DealAnnotation alloc]init];
            anno.coordinate=CLLocationCoordinate2DMake(business.latitude, business.longitude);
            anno.title=business.name;
            anno.subtitle=deal.title;
            MetadataModel *meta=[MetadataModel shared];
            if ([self.selectedCategory isEqualToString:@"全部分类"]||(!self.selectedCategory)) {
                // 获得团购所属的类型
                CategoryModel *category = [[MetadataModel shared] categoryWithDeal:deal];
                if (category.map_icon) {
                    anno.icon=category.map_icon;
                }else{
                    anno.icon=@"ic_category_default";
                }
            }else{
                for (CategoryModel *category in meta.categoryModels) {
                    if ([self.selectedCategory isEqualToString:category.name]||[category.subcategories containsObject:self.selectedCategory]) {
                        anno.icon=category.map_icon;
                        break;
                    }
                }
            }           
            if ([self.mapV.annotations containsObject:anno]) break;            
            [self.mapV addAnnotation:anno];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
