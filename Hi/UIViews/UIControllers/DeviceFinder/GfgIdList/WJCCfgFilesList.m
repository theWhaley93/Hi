//
//  WJCCfgFilesList.m
//  Hi
//
//  Created by apple on 2018/3/29.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCCfgFilesList.h"
#import "WJCCfgFilesItem.h"
//#import "LoadingViewForOC.h"
#import "WJCCloudFiles.h"
#import "WJCDevice.h"
#import "WJCUiMainController.h"
//#import "WJCMainViewController.h"
#import "LCLoadingHUD.h"

@interface WJCCfgFilesList ()<WJCCloudDownFileDelegate>
@property (nonatomic,strong)  WJCCfgFileListModel *cfgFiles;  //cfg文件列表
//@property (nonatomic,weak)  LoadingViewForOC *loadingView;  wjc20180524
@end

@implementation WJCCfgFilesList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"参数文件列表";


    
    //清除多余cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 52;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    _cfgFiles = [[WJCCfgFileListModel alloc] init];
    
    [NSThread detachNewThreadSelector:@selector(loadFileInfo) toTarget:self withObject:nil];
}
#pragma mark - UI操作
/**跳转至主界面
 */
- (void)jumpIntoMainControllerForm{
    //    WJCUiMainForm *mainForm = [[WJCUiMainForm alloc] init];
    hiDevice.isOffline = YES;
    WJCUiMainController *mainForm = [[WJCUiMainController alloc] initWithIsOffline:hiDevice.isOffline];
//    WJCMainViewController *mainForm = [[WJCMainViewController alloc] initWithIsOffline:YES];
    
    [self.navigationController pushViewController:mainForm animated:YES];

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

- (void)stopLoading{
//    [self.loadingView hideLoadingView];wjc20180524
    [LCLoadingHUD hideInKeyWindow];
}

- (void)loadFileInfo{
    
    [_cfgFiles loadFromCloud];
    //[_loadingView performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:YES];

    dispatch_async(dispatch_get_main_queue(), ^{
                      // UI更新代码

        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return _cfgFiles.fileList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    WJCCfgFilesItem *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [WJCCfgFilesItem cfgFilesItemWithTableView:tableView];
    }
    [cell loadWithCfgFileModel:self.cfgFiles.fileList[indexPath.row]];
    // Configure the cell...
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}


#pragma mark - WJCCloudDownFileDelegate 参数下载代理返回方法
- (void)downLoadCfgFileResult:(Boolean)rResult downResult:(WJCDownLoadResult)rDownResult cfgId:(int)rCfgId{

    
    if (rResult) {
        NSLog(@"成功");
        NSLog(@"%d",rDownResult);
        
        [hiDevice loadFileWithCfgId:rCfgId];
        [self performSelectorOnMainThread:@selector(jumpIntoMainControllerForm) withObject:nil waitUntilDone:NO];
    } else {
        NSLog(@"%d",rDownResult);
        [self popDialogWithTittle:@"提示"  message:@"下载失败" ];
        
    }
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger rind = indexPath.row;

//    _loadingView = [LoadingViewForOC showLoadingWith:self.view];
//    _loadingView = [LoadingViewForOC showLoadingWithWindow];wjc20180524
    [LCLoadingHUD showLoading:@"正在载入中..."];
    if (_cfgFiles.fileList[rind]->localExist) {

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            hiDevice.cfgId = _cfgFiles.fileList[rind].cfgId;
            hiDevice.isOffline = YES;
            [hiDevice loadFileWithCfgId:hiDevice.cfgId];
            [self performSelectorOnMainThread:@selector(jumpIntoMainControllerForm) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
//            [_loadingView hideLoadingView];
        });
//        [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];

        
    } else if (_cfgFiles.fileList[rind]->cloudExist){
        _cfgFiles.fileList[rind]->theDelegate = self;
        hiDevice.cfgId = _cfgFiles.fileList[rind].cfgId;
        hiDevice.isOffline = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_cfgFiles.fileList[rind] downloadCfgFiles];
        });
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
