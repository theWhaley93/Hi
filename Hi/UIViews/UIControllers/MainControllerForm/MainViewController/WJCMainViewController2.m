//
//  WJCMainViewController2.m
//  Hi
//
//  Created by apple on 2018/4/11.
//  Copyright © 2018年 apple. All rights reserved.
//

#define ScrW [UIScreen mainScreen].bounds.size.width
#define ScrH [UIScreen mainScreen].bounds.size.height

#import "WJCMainViewController2.h"
#import "WJCUiMainController.h"
#import "WJCWorklistController.h"
#import "WJCChartController.h"

@interface WJCMainViewController2 ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong)  UIButton *btn1;  //
@property (nonatomic,strong)  UIButton *btn2;  //
@property (nonatomic,strong)  UIButton *btn3;  //
@property (nonatomic, strong) UICollectionView *bigCollectionView;
@property (nonatomic,strong)  WJCUiMainController *mainForm;  //
@property (nonatomic,strong)  WJCWorklistController *worklistForm;  //
@property (nonatomic,strong)  WJCChartController *chartForm;  //
@end

@implementation WJCMainViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    UITabBarController *tabBarController = [[UITabBarController alloc] init];
//    [tabBarController.tabBar setBackgroundColor:[UIColor redColor]];//[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1]];
//    [tabBarController.tabBar setTintColor:[UIColor greenColor]];////[UIColor colorWithRed:2/255.0f green:187/255.0f blue:0/255.0f alpha:1]];
    
    UINavigationController *mainFormNav = [[UINavigationController alloc] initWithRootViewController:self.mainForm];
    
    UINavigationController *worklistFormNav = [[UINavigationController alloc] initWithRootViewController:self.worklistForm];
    
    UINavigationController *chartFormNav = [[UINavigationController alloc] initWithRootViewController:self.chartForm];
    
//    [tabBarController setViewControllers:@[mainFormNav,worklistFormNav,chartFormNav]];

//    [self addChildViewController:tabBarController];
//    tabBarController.tabBar.hidden = YES;
//    [self.view addSubview:tabBarController.view];
    [self addChildViewController:self.mainForm];
    [self.view addSubview:self.mainForm.view];
    
    
//    UITableView *tab = [[UITableView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:tab];
    _btn1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 68, 40, 30)];
    _btn1.titleLabel.text = @"btn1";
    _btn1.backgroundColor = [UIColor blueColor];
    _btn1.tag = 0;

    [_btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    _btn2 = [[UIButton alloc] initWithFrame:CGRectMake(60, 68, 40, 30)];
    _btn2.tag = 0;
    _btn2.titleLabel.text = @"btn2";

    [_btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    _btn3 = [[UIButton alloc] initWithFrame:CGRectMake(110, 68, 40, 30)];
    _btn3.tag = 0;
    _btn3.titleLabel.text = @"btn3";

    [_btn3 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn1];
    [self.view addSubview:_btn2];
    [self.view addSubview:_btn3];
//    [self.view addSubview:self.bigCollectionView];
    // Do any additional setup after loading the view.
}


- (instancetype)initWithIsOffline:(Boolean)rIsOffline{
    if (self = [super init]) {
        _isOffline = rIsOffline;
    }
    return self;
}

- (void)btnClick:(UIButton*) sender{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WJCUiMainController *)mainForm{
    if (_mainForm == nil) {
        _mainForm = [[WJCUiMainController alloc] initWithIsOffline:_isOffline];
        [_mainForm.tabBarItem setTitle:@"PARAMETERS"];
        [_mainForm.tabBarItem setImage:[UIImage imageNamed:@"if_hidevice"]];
        
    }
    return _mainForm;
}

- (WJCWorklistController *)worklistForm{
    if (_worklistForm == nil) {
        _worklistForm = [[WJCWorklistController alloc] init];
        [_worklistForm.tabBarItem setTitle:@"WORKLIST"];
        [_worklistForm.tabBarItem setImage:[UIImage imageNamed:@"if_hiworklist"]];
        
    }
    return _worklistForm;
}

- (WJCChartController *)chartForm{
    if (_chartForm == nil) {
        _chartForm = [[WJCChartController alloc] init];
        [_chartForm.tabBarItem setTitle:@"CHART"];
        [_chartForm.tabBarItem setImage:[UIImage imageNamed:@"if_hichart"]];
        
    }
    return _chartForm;
}

- (UICollectionView *)bigCollectionView
{
    if (_bigCollectionView == nil) {
        // 高度 = 屏幕高度 - 导航栏高度64 - 频道视图高度44
        CGFloat h = ScrH - 64 - 30 ;
        CGRect frame = CGRectMake(0, 30, ScrW, h);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _bigCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        _bigCollectionView.backgroundColor = [UIColor whiteColor];
        _bigCollectionView.delegate = self;
        _bigCollectionView.dataSource = self;
//        [_bigCollectionView registerClass:[DDChannelCell class] forCellWithReuseIdentifier:reuseID];
        
        // 设置cell的大小和细节
        flowLayout.itemSize = _bigCollectionView.bounds.size;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        _bigCollectionView.pagingEnabled = YES;
        _bigCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _bigCollectionView;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    DDChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
//    DDChannelModel *channel = _list_now[indexPath.row];
//    cell.urlString = channel.urlString;
//
//    // 如果不加入响应者链，则无法利用NavController进行Push/Pop等操作。
//    [self addChildViewController:(UIViewController *)cell.newsTVC];
//    return cell;
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
//    WJCUiMainController *main = [[WJCUiMainController alloc] initWithIsOffline:NO];
//    [cell addSubview:main.view];
//    [self addChildViewController:main];
    return cell;
    
}


#pragma mark - UICollectionViewDelegate
/** 正在滚动 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGFloat value = scrollView.contentOffset.x / scrollView.frame.size.width;
//    if (value < 0) {return;} // 防止在最左侧的时候，再滑，下划线位置会偏移，颜色渐变会混乱。
//
//    NSUInteger leftIndex = (int)value;
//    NSUInteger rightIndex = leftIndex + 1;
//    if (rightIndex >= [self getLabelArrayFromSubviews].count) {  // 防止滑到最右，再滑，数组越界，从而崩溃
//        rightIndex = [self getLabelArrayFromSubviews].count - 1;
//    }
//
//    CGFloat scaleRight = value - leftIndex;
//    CGFloat scaleLeft  = 1 - scaleRight;
//
//    DDChannelLabel *labelLeft  = [self getLabelArrayFromSubviews][leftIndex];
//    DDChannelLabel *labelRight = [self getLabelArrayFromSubviews][rightIndex];
//
//    labelLeft.scale  = scaleLeft;
//    labelRight.scale = scaleRight;
//
//    //     NSLog(@"value = %f leftIndex = %zd, rightIndex = %zd", value, leftIndex, rightIndex);
//    //     NSLog(@"左%f 右%f", scaleLeft, scaleRight);
//    //     NSLog(@"左：%@ 右：%@", labelLeft.text, labelRight.text);
//
//    // 点击label会调用此方法1次，会导致【scrollViewDidEndScrollingAnimation】方法中的动画失效，这时直接return。
//    if (scaleLeft == 1 && scaleRight == 0) {
//        return;
//    }
//
//    // 下划线动态跟随滚动：马勒戈壁的可算让我算出来了
//    _underline.centerX = labelLeft.centerX   + (labelRight.centerX   - labelLeft.centerX)   * scaleRight;
//    _underline.width   = labelLeft.textWidth + (labelRight.textWidth - labelLeft.textWidth) * scaleRight;
}

/** 手指滑动BigCollectionView，滑动结束后调用 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if ([scrollView isEqual:self.bigCollectionView]) {
//        [self scrollViewDidEndScrollingAnimation:scrollView];
//    }
}

/** 手指点击smallScrollView */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
//    // 获得索引
//    NSUInteger index = scrollView.contentOffset.x / self.bigCollectionView.width;
//    // 滚动标题栏到中间位置
//    DDChannelLabel *titleLable = [self getLabelArrayFromSubviews][index];
//    CGFloat offsetx   =  titleLable.center.x - _smallScrollView.width * 0.5;
//    CGFloat offsetMax = _smallScrollView.contentSize.width - _smallScrollView.width;
//    // 在最左和最右时，标签没必要滚动到中间位置。
//    if (offsetx < 0)         {offsetx = 0;}
//    if (offsetx > offsetMax) {offsetx = offsetMax;}
//    [_smallScrollView setContentOffset:CGPointMake(offsetx, 0) animated:YES];
//
//    // 先把之前着色的去色：（快速滑动会导致有些文字颜色深浅不一，点击label会导致之前的标题不变回黑色）
//    for (DDChannelLabel *label in [self getLabelArrayFromSubviews]) {
//        label.textColor = [UIColor blackColor];
//    }
//    // 下划线滚动并着色
//    [UIView animateWithDuration:0.5 animations:^{
//        _underline.width = titleLable.textWidth;
//        _underline.centerX = titleLable.centerX;
//        titleLable.textColor = AppColor;
//    }];
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
