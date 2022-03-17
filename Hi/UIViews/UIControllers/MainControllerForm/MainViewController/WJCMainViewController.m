//
//  WJCMainViewController.m
//  Hi
//
//  Created by apple on 2018/4/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCMainViewController.h"
#import "WJCUiMainController.h"
#import "WJCWorklistController.h"
#import "WJCChartController.h"

@interface WJCMainViewController ()
@property (nonatomic,strong)  WJCUiMainController *mainForm;  //
@property (nonatomic,strong)  WJCWorklistController *worklistForm;  //
@property (nonatomic,strong)  WJCChartController *chartForm;  //

@end

@implementation WJCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tabBar setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1]];
    [self.tabBar setTintColor:[UIColor colorWithRed:2/255.0f green:187/255.0f blue:0/255.0f alpha:1]];
    
    UINavigationController *mainFormNav = [[UINavigationController alloc] initWithRootViewController:self.mainForm];
    
    UINavigationController *worklistFormNav = [[UINavigationController alloc] initWithRootViewController:self.worklistForm];
    
    UINavigationController *chartFormNav = [[UINavigationController alloc] initWithRootViewController:self.chartForm];
    
    [self setViewControllers:@[mainFormNav,worklistFormNav,chartFormNav]];



    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithIsOffline:(Boolean)rIsOffline{
    if (self = [super init]) {
        _isOffline = rIsOffline;
    }
    return self;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
