//
//  WJCViewController.m
//  Hi
//
//  Created by apple on 2018/3/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCViewController.h"
#import "ViewController.h"
#import "WJCUiDeviceFinder.h"
#import "WJCRemoteDeviceFinderController.h"
#import "WJCInstructionViewController.h"
#import <PgyUpdate/PgyUpdateManager.h>
#import "WJCGlobalConstants.h"
#import "WJCParaSearchViewController.h"

#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

@interface WJCViewController ()<UITableViewDataSource,UITableViewDelegate>

//@property (weak, nonatomic) IBOutlet UITableView *modeTable;
@property (nonatomic,strong)  UITableView *modeTable;  //
@property (nonatomic,strong)  UIImageView *qrCodeView;  //
@property (nonatomic)  Boolean showQrCode;  //

@property (nonatomic,strong)  NSMutableArray *showArray;    //显示内容
@property (weak, nonatomic) IBOutlet UILabel *verLabel;

@end

@implementation WJCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modeTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];//[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.modeTable.dataSource = self;
    self.modeTable.delegate = self;
    [self.view addSubview:self.modeTable];
    self.modeTable.separatorStyle = UITableViewCellSelectionStyleNone;
    
    int bottonMinusHeight =105;
    int statusbarFrameH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if(statusbarFrameH>40)
        bottonMinusHeight = 130;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width /2-85, [UIScreen mainScreen].bounds.size.height-bottonMinusHeight, 170, 30)];
    label.font = [UIFont fontWithName:@"Arial" size:13.0];
    label.text =[NSString stringWithFormat:@"版本号:%@%@(2021/02/18)",@"v",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    label.textColor = [UIColor blackColor];

    [self.modeTable addSubview:label];

//    self.verLabel.text =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    self.navigationItem.title = @"Hi驱动器调试软件";
    self.showArray = [[NSMutableArray alloc] init];
//    NSDictionary *dict = @{@"tittle":@"远程控制模式",@"image":@"if_cloud",@"context":@"由远程端控制查看驱动器状态"};
    NSDictionary *dict = @{@"tittle":@"远程控制模式",@"image":@"if_hand_cloud",@"context":@"由远程端控制查看驱动器状态"};
    [self.showArray addObject:dict];
    
//    NSDictionary *dict1 = @{@"tittle":@"本地控制模式",@"image":@"if_localp",@"context":@"直接在手机上查看驱动器状态"};
    NSDictionary *dict1 = @{@"tittle":@"本地控制模式",@"image":@"if_hand_local",@"context":@"直接在手机上查看驱动器状态"};
    [self.showArray addObject:dict1];
    
//    NSDictionary *dict2 = @{@"tittle":@"说明书",@"image":@"if_document",@"context":@"Hi驱动器说明书"};
    NSDictionary *dict2 = @{@"tittle":@"说明书",@"image":@"if_hand_instruction",@"context":@"Hi驱动器说明书"};
    [self.showArray addObject:dict2];

    NSDictionary *dict5 = @{@"tittle":@"EtherCAT对象字典",@"image":@"if_hand_searchPara",@"context":@"对象字典查询"};
    [self.showArray addObject:dict5];
//    NSDictionary *dict3 =  @{@"tittle":@"检查软件版本",@"image":@"if_arrowdown",@"context":@"查询是否需要更新软件"};
//    [NSString stringWithFormat:@"%@%@",@"检查软件版本",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
//    NSDictionary *dict3 =  @{@"tittle":[NSString stringWithFormat:@"%@%@",@"检查软件版本",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]],@"image":@"if_hand_refresh",@"context":@"查询是否需要更新软件"};
//    NSDictionary *dict3 =  @{@"tittle":@"检查软件版本",@"image":@"if_hand_refresh",@"context":[NSString stringWithFormat:@"%@%@",@"查询是否需要更新软件 v",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]};
//    NSDictionary *dict3 =  @{@"tittle":@"检查软件版本",@"image":@"if_hand_refresh",@"context":@"查询是否需要更新软件"};
//    NSDictionary *dict3 =  @{@"tittle":[NSString stringWithFormat:@"%@%@%@",@"检查软件版本(v",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],@")"],@"image":@"if_hand_refresh",@"context":@"查询是否需要更新软件"};
    NSDictionary *dict3 =  @{@"tittle":[NSString stringWithFormat:@"%@",@"检查软件版本"],@"image":@"if_hand_refresh",@"context":@"查询是否需要更新软件"};
    [self.showArray addObject:dict3];
    
//    NSDictionary *dict4 =  @{@"tittle":@"软件二维码",@"image":@"if_qrcode",@"context":@"扫描二维码可下载软件"};
    NSDictionary *dict4 =  @{@"tittle":@"软件二维码",@"image":@"if_hand_download",@"context":@"扫描二维码可下载软件"};
    [self.showArray addObject:dict4];
//    self.modeTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view from its nib.
//        self.modeTable.sectionFooterHeight = 20;
//        self.modeTable.sectionHeaderHeight = 0;
    
    self.modeTable.sectionHeaderHeight = 10;
    self.modeTable.sectionFooterHeight = 10;
    _modeTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _modeTable.bounds.size.width, 20.0f)];
    
    _qrCodeView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width /2 -100, [UIScreen mainScreen].bounds.size.height /2-30, 200, 0)];
    [_qrCodeView setImage:[UIImage imageNamed:@"QRCode_336"]];
    [self.view addSubview:_qrCodeView];
    _showQrCode = NO;
    
//    self.modeTable.userInteractionEnabled = YES;
//    self.modeTable.multipleTouchEnabled = YES;
    _qrCodeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_qrCodeView addGestureRecognizer:singleTap];
    
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:PGY_APPKEY];   // 请将 PGY_APP_ID 换成应用的 App Key
    [[PgyUpdateManager sharedPgyManager] checkUpdate];
    
//    NSLog(@"%@",[[NSBundle mainBundle] bundleIdentifier]);
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.modeTable.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)handleTap:(UIGestureRecognizer *)gesture{
    if (_showQrCode) {
        _showQrCode = NO;
        _qrCodeView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width /2 -100, [UIScreen mainScreen].bounds.size.height /2-30, 200, 0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.showArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];

//        cell.textLabel.text = [NSString stringWithFormat:@"%ld组%zd行-其他数据",indexPath.section,indexPath.row];
    if (indexPath.section<6) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSDictionary *dict = self.showArray[indexPath.section];
        
        cell.textLabel.text = dict[@"tittle"];
        cell.imageView.image = [UIImage imageNamed:dict[@"image"]];
        CGSize itemSize = CGSizeMake(40, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cell.detailTextLabel.text = dict[@"context"];
    }

    return cell;

}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//
//    return @" ";
//}
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (section == 3) {
//        return @" ";
//    }
//    return @"";
//}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{//远程调试
            WJCRemoteDeviceFinderController *remoteFinder = [[WJCRemoteDeviceFinderController alloc] init];
            [self.navigationController pushViewController:remoteFinder animated:YES];
            break;
        }
        case 1:{
            WJCUiDeviceFinder *deviceF = [[WJCUiDeviceFinder alloc] init];
            [self.navigationController pushViewController:deviceF animated:YES];
            break;
        }
        case 2:{
            WJCInstructionViewController *insV = [[WJCInstructionViewController alloc] init];
            [self.navigationController pushViewController:insV animated:YES];
            break;
        }
        case 3:{
            
            WJCParaSearchViewController *insV = [[WJCParaSearchViewController alloc] init];
            [self.navigationController pushViewController:insV animated:YES];
            break;
        }
        case 4:{
//            [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:PGY_APPKEY];   // 请将 PGY_APP_ID 换成应用的 App Key
//            [[PgyUpdateManager sharedPgyManager] checkUpdate];
                [[PgyUpdateManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(updateMethod:)];
            break;
        }
        case 5:{
            _showQrCode = YES;
            _qrCodeView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width /2 -100, [UIScreen mainScreen].bounds.size.height /2-30, 200, 200);
            break;}

    }
}




/**弹出提示框
 */
- (void)popDialogWithTittle:(NSString *)rTittle message:(NSString *)rMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:rTittle message:rMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [alert addAction:okAlert];
    [self presentViewController:alert animated:YES completion:nil];
}
/**
 *  检查更新回调
 *
 *  @param response 检查更新的返回结果
 */
- (void)updateMethod:(NSDictionary *)response
{
    if (response[@"downloadURL"]) {
        
        [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:PGY_APPKEY];   // 请将 PGY_APP_ID 换成应用的 App Key
        [[PgyUpdateManager sharedPgyManager] checkUpdate];
    } else {
        [self popDialogWithTittle:@"提示" message:@"已是最新版本"];
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
