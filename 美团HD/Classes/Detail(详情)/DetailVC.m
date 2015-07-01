//
//  MTDetailViewController.m
//  美团HD
//
//  Created by apple on 14/11/27.
//  Copyright (c) 2014年  tarena. All rights reserved.
//

#import "DetailVC.h"
#import "DealModel.h"
#import "MTConst.h"
#import "DPAPI.h"
#import "MBProgressHUD+MJ.h"
#import "UIImageView+WebCache.h"
#import "DealTool.h"

@interface DetailVC () <UIWebViewDelegate,DPRequestDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *refundableAnyTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *refundableExpireButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftTimeButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *purchase_countButton;
@property (weak, nonatomic) IBOutlet UIButton *collocButton;
@property(nonatomic,weak)DealTool *dealTool;

@end

@implementation DetailVC

-(DealTool *)dealTool{
    if (_dealTool==nil) {
        _dealTool=[DealTool shardDealTool];
    }
    return _dealTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置背景
    self.view.backgroundColor = MTGlobalBg;
    
    //加载网页
    self.webView.hidden = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_h5_url]]];
    
    //设置基本信息
    self.titleLabel.text = self.deal.title;
    self.descLabel.text = self.deal.desc;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.deal.s_image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    [self.purchase_countButton setTitle:[NSString stringWithFormat:@"已售出：%@份",self.deal.purchase_count] forState:UIControlStateNormal];
    
    self.collocButton.selected=[self.dealTool isCollected:self.deal];    
    
    NSLog(@"详情： 是否支持随时退：  %d,%d",self.collocButton.selected,[self.dealTool isCollected:self.deal]);
    
    // 设置剩余时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *dead = [fmt dateFromString:self.deal.purchase_deadline];
    // 追加1天
    dead = [dead dateByAddingTimeInterval:24 * 60 * 60];
    //获取当前时间
    NSDate *now = [NSDate date];
    //设置计算时间返回格式
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    //计算两个时间的差值
    NSDateComponents *cmps = [[NSCalendar currentCalendar] components:unit fromDate:now toDate:dead options:0];
    if (cmps.day > 365) {
        [self.leftTimeButton setTitle:@"一年内不过期" forState:UIControlStateNormal];
    } else {
        [self.leftTimeButton setTitle:[NSString stringWithFormat:@"%ld天%ld小时%ld分钟", (long)cmps.day, (long)cmps.hour, (long)cmps.minute] forState:UIControlStateNormal];
    }
    
    // 发送请求获得更详细的团购数据
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"deal_id"] = self.deal.deal_id;
    [api requestWithURL:@"v1/deal/get_single_deal" params:params delegate:self];

}

//返回
- (IBAction)ClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//收藏
- (IBAction)ClickColloc:(UIButton *)sender {
    
    //判断键盘的选中状态，如果没有被选中就收藏
    if (sender.selected) {
        [MBProgressHUD showError:@"取消成功" toView:self.view];
        [self.dealTool removeCollectDeal:self.deal];        
    }else{
        [MBProgressHUD showError:@"收藏成功" toView:self.view];
        [self.dealTool addCollectDeal:self.deal];
    }
    
    sender.selected=!sender.selected;
}

//购买
- (IBAction)ClickBuy:(id)sender {
    //在软件内购买
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_url]]];
    //在浏览器内购买
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.deal.deal_url]];
}

/**
 *  返回控制器支持的方向
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - DPRequestDelegate
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    self.deal = [DealModel objectWithKeyValues:[result[@"deals"] firstObject]];
    // 设置退款信息
    self.refundableAnyTimeButton.selected = !self.deal.restrictions.is_refundable;
    self.refundableExpireButton.selected = !self.deal.restrictions.is_refundable;
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    [MBProgressHUD showError:@"网络繁忙,请稍后再试" toView:self.view];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView.request.URL.absoluteString isEqualToString:self.deal.deal_h5_url]) {
        // 旧的HTML5页面加载完毕
        NSString *ID = [self.deal.deal_id substringFromIndex:[self.deal.deal_id rangeOfString:@"-"].location + 1];
        NSString *urlStr = [NSString stringWithFormat:@"http://lite.m.dianping.com/group/deal/moreinfo/%@", ID];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
        
    } else { // 详情页面加载完毕
        // 用来拼接所有的JS
        NSMutableString *js = [NSMutableString string];
        // 删除header
        [js appendString:@"var header = document.getElementsByTagName('header')[0];"];
        [js appendString:@"header.parentNode.removeChild(header);"];
        // 删除顶部的购买
        //[js appendString:@"var box = document.getElementsByClassName('cost-box')[0];"];
        //[js appendString:@"box.parentNode.removeChild(box);"];
        // 删除底部的购买
        [js appendString:@"var buyNow = document.getElementsByClassName('buy-now')[0];"];
        [js appendString:@"buyNow.parentNode.removeChild(buyNow);"];
        
        // 利用webView执行JS
        [webView stringByEvaluatingJavaScriptFromString:js];

        webView.hidden = NO;
        // 隐藏正在加载
        [self.loadingView stopAnimating];
    }
}



@end
