//
//  WJCInstructionViewController.m
//  Hi
//
//  Created by apple on 2018/6/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCInstructionViewController.h"
#import "YCXMenu.h"
#import <WebKit/WebKit.h>

@interface WJCInstructionViewController (){
    float t1,t2,t3,t4,t5,t6;
    CALayer *progressLayer;
}
@property (strong, nonatomic) WKWebView *wwebView;
@property (nonatomic , strong) NSMutableArray *items;   //bar 新建／打开文件夹

@end

@implementation WJCInstructionViewController
@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setRightButtons];
    self.title = @"Hi2xx系列驱动器";
    /*
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"HiV5.50-V1.01" ofType:@"pdf"];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSFileManager * file = [NSFileManager defaultManager];
//    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/HiV5.31.pdf"];
    NSString *tempS = @"http://co.haitianiot.com:7010/doc/Hi200-Basic-zh.pdf";
    NSURL *fileUrl = [NSURL URLWithString:tempS];
    [_webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
    [_webView setScalesPageToFit:YES];
    _webView.scalesPageToFit = YES;
    */
    
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
    t6 = [UIScreen mainScreen].bounds.size.height;
//    WKWebView *wwebview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    WKWebView *wwebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, t1+t2-t3, statusBarFrame.size.width, t6-(t1+t2-t3))];
    [self.view addSubview:wwebview];
    _wwebView = wwebview;
    
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
    
    NSString *string = @"http://co.haitianiot.com:7010/doc/Hi200-Basic-zh.pdf";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
    [wwebview loadRequest:request];
    

}
//- (void)dealloc
//{
//    [_wwebView removeObserver:self forKeyPath:@"estimatedProgress"];
//}
- (void)deleteWebCache {
//allWebsiteDataTypes清除所有缓存
 NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];

    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];

    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
}
- (void)setRightButtons{
    //    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenu)];
    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_more3"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = barMenu;
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
#pragma mark - 菜单栏内容
- (NSMutableArray *)items {
    if (!_items) {
        
        // set title
        //        YCXMenuItem *menuTitle = [YCXMenuItem menuTitle:@"Menu" WithIcon:nil];
        //        menuTitle.foreColor = [UIColor whiteColor];
        //        menuTitle.titleFont = [UIFont boldSystemFontOfSize:20.0f];
        
        //set logout button
        //        YCXMenuItem *logoutItem = [YCXMenuItem menuItem:@"退出" image:nil target:self action:@selector(logout:)];
        //        logoutItem.foreColor = [UIColor redColor];
        //        logoutItem.alignment = NSTextAlignmentCenter;
        
        //set item
        _items = [@[
                    [YCXMenuItem menuItem:@"Hi2xx系列驱动器"
                                    image:nil
                                      tag:100
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"Hi200油压控制"
                                    image:nil
                                      tag:101
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"Hi300/360驱动器"
                                    image:nil
                                      tag:102
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"Hi300油压控制"
                                    image:nil
                                      tag:103
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"清除说明书缓存"
                                    image:nil
                                      tag:103
                                 userInfo:@{@"title":@"Menu"}]
                    //                    [YCXMenuItem menuItem:@"曲线采集"
                    //                                    image:nil
                    //                                      tag:102
                    //                                 userInfo:@{@"title":@"Menu"}]
                    ] mutableCopy];
    }
    return _items;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
}
- (void)showMenu{
    [YCXMenu setTintColor:[UIColor darkGrayColor]];
    [YCXMenu setSelectedColor:[UIColor lightGrayColor]];
    if ([YCXMenu isShow]){
        [YCXMenu dismissMenu];
    } else {
        float tempHe = 0;
        if ([[UIApplication sharedApplication] statusBarFrame].size.height >44) {
            tempHe = 20;
        }
        [YCXMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 50, t1+t2-t3, 50, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
            
            //点击右上角菜单
            switch (index) {
                case 0:{
                    self.title = @"Hi2xx系列驱动器";
                    
                    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"HiV5.50-V1.01" ofType:@"pdf"];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    //    NSFileManager * file = [NSFileManager defaultManager];
                    //    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/HiV5.31.pdf"];
                    NSString *tempS = @"http://co.haitianiot.com:7010/doc/Hi200-Basic-zh.pdf";
                    NSURL *fileUrl = [NSURL URLWithString:tempS];
//                    [_webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
//                    [_webView setScalesPageToFit:YES];
//                    _webView.scalesPageToFit = YES;

                    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
                    [_wwebView loadRequest:request];

                    break;
                }
                case 1:{
                    self.title = @"Hi200油压控制";
                    
                    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"V5.50-190510" ofType:@"pdf"];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    //    NSFileManager * file = [NSFileManager defaultManager];
                    //    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/HiV5.31.pdf"];
                    NSString *tempS = @"http://co.haitianiot.com:7010/doc/Hi200-Oil-zh.pdf";
                    NSURL *fileUrl = [NSURL URLWithString:tempS];
//                    [_webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
//                    [_webView setScalesPageToFit:YES];
//                    _webView.scalesPageToFit = YES;
                    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
                    [_wwebView loadRequest:request];
                    break;
                }
                case 2:{
                    self.title = @"Hi300/360驱动器";
                    
                    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"Hi300:360" ofType:@"pdf"];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    //    NSFileManager * file = [NSFileManager defaultManager];
                    //    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/HiV5.31.pdf"];
                    NSString *tempS = @"http://co.haitianiot.com:7010/doc/Hi300&360系列交流伺服驱动器使用手册（中英文）.pdf";
                    //处理中文
                    NSString *logStr = [tempS stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSURL *fileUrl = [NSURL URLWithString:logStr];
//                    [_webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
//                    [_webView setScalesPageToFit:YES];
//                    _webView.scalesPageToFit = YES;
                    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
                    [_wwebView loadRequest:request];
                    break;
                }
                case 3:{
                    self.title = @"Hi300油压控制";
                    
                    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"Hi300yy" ofType:@"pdf"];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    //    NSFileManager * file = [NSFileManager defaultManager];
                    //    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/HiV5.31.pdf"];
                    NSString *tempS = @"http://co.haitianiot.com:7010/doc/Hi300系列驱动器油压控制使用手册（中文）.pdf";
                    NSString *logStr = [tempS stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    NSURL *fileUrl = [NSURL URLWithString:logStr];
//                    [_webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
//                    [_webView setScalesPageToFit:YES];
//                    _webView.scalesPageToFit = YES;
                    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
                    [_wwebView loadRequest:request];
                    break;
                }
                case 4:{
                    [self deleteWebCache];
                    break;
                }
                default:
                    break;
            }
            
            //            NSLog(@"%@",item);
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
