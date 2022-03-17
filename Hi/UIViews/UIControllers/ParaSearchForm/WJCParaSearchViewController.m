//
//  WJCParaSearchViewController.m
//  Hi
//
//  Created by 王鲸超 on 2021/1/21.
//  Copyright © 2021 apple. All rights reserved.
//

#import "WJCParaSearchViewController.h"
#import <WebKit/WebKit.h>
@interface WJCParaSearchViewController (){
    float t1,t2,t3,t4,t5,t6;
    CALayer *progressLayer;
}
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation WJCParaSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"EtherCAT对象字典";
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    config.selectionGranularity = WKSelectionGranularityDynamic;

    config.allowsInlineMediaPlayback = YES;

    WKPreferences *preferences = [WKPreferences new];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    t1 = self.navigationController.navigationBar.frame.size.height;
    t2 = statusBarFrame.size.height;
    t3 = 0;
    if(t2==40)
        t3=20;
    t4 = self.view.bounds.size.width;
    t5 = self.view.bounds.size.height;
    t6 = [UIScreen mainScreen].bounds.size.height;
    
    WKWebView *wwebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, t1+t2-t3, statusBarFrame.size.width, t6-(t1+t2-t3))];
//    WKWebView *wwebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, t5)];
    [self.view addSubview:wwebview];
    
//    self.hidesBottomBarWhenPushed = YES;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    wwebview.scrollView.showsVerticalScrollIndicator = NO;
//    self.zkSegment = [ZKSegment
//                      zk_segmentWithFrame:CGRectMake(0, t1+t2-t3, self.view.bounds.size.width, 45)
//                      style:self.zkSegmentStyle];
    
    [wwebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    // 进度条
    UIView * progress = [[UIView alloc] initWithFrame:CGRectMake(0, t1+t2-t3, CGRectGetWidth(self.view.frame), 3)];
    progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progress];
    // 隐式动画
    CALayer * layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor systemBlueColor].CGColor;
    [progress.layer addSublayer:layer];
    progressLayer = layer;
    
    NSString *string = @"http://co.haitianiot.com:7010/admin/pscada/ethercat/hiEthercatPara/ethercatParaList";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
    [wwebview loadRequest:request];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"change == %@",change);
        progressLayer.opacity = 1;
        progressLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[NSKeyValueChangeNewKey] floatValue], 3);
        if ([change[NSKeyValueChangeNewKey] floatValue] == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                progressLayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
