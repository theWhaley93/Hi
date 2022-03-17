//
//  WJCUiDeviceFinder.m
//  Hi
//
//  Created by apple on 2018/3/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCUiDeviceFinder.h"
#import "WJCDeviceFinder.h"
#import "WJCWifiDeviceInfo.h"
#import "GCDAsyncUdpSocket.h"
#import "WJCDevice.h"
#import "WJCUiMainForm.h"
#import "WJCGlobalConstants.h"
#import "WJCCommonFunctions.h"
#import "WJCCloudFiles.h"
#import "WJCUiMainController.h"
#import "WJCCfgFilesList.h"
//#import "LoadingViewForOC.h" wjc20180524
#import "WJCMainViewController2.h"
#import "LCLoadingHUD.h"
#import "SVProgressHUD.h"

@interface WJCUiDeviceFinder ()<WJCCloudDownFileDelegate,WJCUpdateFileDelegate>{
//    UIActivityIndicatorView *indicator;
}

//@property (nonatomic,strong)  LoadingViewForOC *loadingView;  //wjc20180524
@property (nonatomic,strong)  NSMutableArray<WJCWifiDeviceInfo *> *wifiDevice;    //显示内容
@property (nonatomic,strong)  GCDAsyncUdpSocket *udpSocketT;  //


@end

@implementation WJCUiDeviceFinder


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (hiDevice == nil) {
        hiDevice = [[WJCDevice alloc] init];
    }


    //中间旋转效果
//    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    indicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
//    indicator.hidesWhenStopped = YES;
//    [self.view addSubview:indicator];
    
    self.navigationItem.title = @"驱动器设备列表";
    self.wifiDevice = [[NSMutableArray alloc] init];
    [self.wifiDevice removeAllObjects];
    
    [self setRightButtons];
    
    //下拉刷新动作，refreshcontrol
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(sendSearchCommand) forControlEvents:UIControlEventValueChanged];
    
    //清除多余cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 55;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    //udp查找设备
    [NSThread detachNewThreadSelector:@selector(sendSearchCommand) toTarget:self withObject:nil];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setRightButtons{
    
    UIBarButtonItem *plusBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_plus"] style:UIBarButtonItemStylePlain target:self action:@selector(doConnectIPManualy)];//
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_refresh2"] style:UIBarButtonItemStylePlain target:self action:@selector(sendSearchCommand)];//
     NSArray *buttonArray = [[NSArray alloc]initWithObjects:refreshBtn,plusBtn, nil];
     self.navigationItem.rightBarButtonItems = buttonArray;
//    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_refresh2"] style:UIBarButtonItemStylePlain target:self action:@selector(sendSearchCommand)];//
//    self.navigationItem.rightBarButtonItem = barMenu;
}

- (void)refreshTableView{
    [self.tableView reloadData];
}
#pragma mark -
- (BOOL)isIPAddressWithString:(NSString *)string{

    if (string.length > 15) {
        return false;
    }

    NSInteger from = 0; //记录截取的初始位置
    NSInteger cutCount = 0; //记录截取次数
    NSInteger length = string.length;

    //    NSInteger to  = 0; //截取长度i-from+1

    for (NSInteger i = 0; i < length; i++) {

        unichar charactor = [string characterAtIndex:i];
        //判断字符规范

        if ( !((charactor>= 48 && charactor<=57) || charactor==46) ) {
            return false;
        }

    //截取，判读是否在ip地址范围

        if ((charactor==46) || (i==length-1)) {

            NSInteger tempInt = [[string substringWithRange:NSMakeRange(from, (i-from+1))] integerValue];

            //NSLog(@"%ld", tempInt);

            if (!(tempInt >= 0 && tempInt <= 255)) {
                return false;
            }

            from = i+1;
            cutCount++;
        }

    }

    //判断截取次数是否满足
    if (cutCount != 4) {
        return false;
    }

    //通过所有检测
    return true;

}
- (void)doConnectIPManualy{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要连接的IP" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //                textField.placeholder = @"请输入worklist名";
        textField.text = @"192.168.2.145";
        [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0];
    }];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if([self isIPAddressWithString:alert.textFields[0].text]){
                    {
            //            [indicator startAnimating];

            //            self.loadingView = [LoadingViewForOC showLoadingWith:self.view];
                        [LCLoadingHUD showLoading:@"正在载入中..."];
            //            self.loadingView = [LoadingViewForOC showLoadingWithWindow];wjc20180524

                        [hiDevice createHiCom:alert.textFields[0].text OnPort:8899];
            //            [NSThread sleepForTimeInterval:1.0f];
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{

                            NSString *recString = COMM_TIMEOUT;
                            int retryTimes = 0;

                            while ((retryTimes <5) && (isErr(recString))) {
                                recString = [hiDevice.hiCom readData:4 subindex:0];
                                [NSThread sleepForTimeInterval:0.05f];
                                retryTimes++;
                            }

                            NSLog(@"%@--times:%d-%@",recString,retryTimes,[NSThread currentThread]);
                            if (isErr(recString)) {
            //                    [indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
                                [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                   // UI更新代码
                                    [self popDialogWithTittle:@"提示"  message:@"通讯失败" ];
                                });
                                
             
                                
                            } else {

                                int recD = strtoul([recString UTF8String], 0, 16);
                                hiDevice.cfgId = recD;
                                if ([WJCHiFileExecutor searchCfgFilesLocal:recD]) {
                                    NSLog(@"本地存在CFGD%d版本参数",recD);
                                    [hiDevice loadFileWithCfgId:recD];
            //                        [indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
                                    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                                    [self performSelectorOnMainThread:@selector(jumpIntoMainControllerForm) withObject:nil waitUntilDone:NO];

                                } else {


                                    //                [indicator startAnimating];
                                    WJCCloudFiles *tempCloud = [[WJCCloudFiles alloc] initWithDelegate:self];
                                    //                [tempCloud setTimeOut];
                                    [tempCloud startDownload:recD];
                                }



                            }
                        });
                    }
            
        } else
            [self popDialogWithTittle:@"提示"  message:@"输入的IP格式有误" ];

        
        
        
    }];
    [alert addAction:okAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else
        return self.wifiDevice.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    
    if (indexPath.section==0) {
        
        cell.textLabel.text = @"离线设备";
        cell.detailTextLabel.text = @"offline";
//        cell.imageView.image = [UIImage imageNamed:@"if_deviceo"];
        cell.imageView.image = [UIImage imageNamed:@"if_hand_offlinedevice"];
        
    }else{

//        cell.imageView.image = [UIImage imageNamed:@"if_device"];
        cell.imageView.image = [UIImage imageNamed:@"if_hand_device"];
        cell.textLabel.text = self.wifiDevice[indexPath.row].name;
        cell.detailTextLabel.text = self.wifiDevice[indexPath.row].ip;
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    //cell图片尺寸适当
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    
    return cell;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"离线设备";
    }
    else{
        return @"在线设备";
    }
    
}
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (section == 3) {
//        return @" ";
//    }
//    return @"";
//}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//
//    return @" ";
//}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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


#pragma mark - Tableview delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    if (indexPath.section == 0) {   //wjc离线进入
        [self jumpIntoOfflineForm];
    } else if (indexPath.section>0) {
        //在线模式
        
//        if (hiDevice == NULL)
        {
//            [indicator startAnimating];

//            self.loadingView = [LoadingViewForOC showLoadingWith:self.view];
            [LCLoadingHUD showLoading:@"正在载入中..."];
//            self.loadingView = [LoadingViewForOC showLoadingWithWindow];wjc20180524
            
            [hiDevice createHiCom:self.wifiDevice[indexPath.row].ip OnPort:8899];
//            [hiDevice createHiCom:@"10.10.10.103" OnPort:8899];
//            [NSThread sleepForTimeInterval:1.0f];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{

                NSString *recString = COMM_TIMEOUT;
                int retryTimes = 0;

                while ((retryTimes <5) && (isErr(recString))) {
                    recString = [hiDevice.hiCom readData:4 subindex:0];
                    [NSThread sleepForTimeInterval:0.05f];
                    retryTimes++;
                }

                NSLog(@"%@--times:%d-%@",recString,retryTimes,[NSThread currentThread]);
                if (isErr(recString)) {
//                    [indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
                    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                    dispatch_async(dispatch_get_main_queue(), ^{
                       // UI更新代码
                        [self popDialogWithTittle:@"提示"  message:@"通讯失败" ];
                    });
                    
 
                    
                } else {

                    int recD = strtoul([recString UTF8String], 0, 16);
                    hiDevice.cfgId = recD;
                    if ([WJCHiFileExecutor searchCfgFilesLocal:recD]) {
                        NSLog(@"本地存在CFGD%d版本参数",recD);
                        [hiDevice loadFileWithCfgId:recD];
//                        [indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
                        [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
                        [self performSelectorOnMainThread:@selector(jumpIntoMainControllerForm) withObject:nil waitUntilDone:NO];

                    } else {


                        //                [indicator startAnimating];
                        WJCCloudFiles *tempCloud = [[WJCCloudFiles alloc] initWithDelegate:self];
                        //                [tempCloud setTimeOut];
                        [tempCloud startDownload:recD];
                    }



                }
            });
        }

        

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


#pragma mark - UI操作
/**跳转至主界面
 */
- (void)jumpIntoMainControllerForm{
    //    WJCUiMainForm *mainForm = [[WJCUiMainForm alloc] init];
    hiDevice.isOffline = NO;
    WJCUiMainController *mainForm = [[WJCUiMainController alloc] initWithIsOffline:hiDevice.isOffline];
//    WJCMainViewController2 *mainForm = [[WJCMainViewController2 alloc] initWithIsOffline:NO];
    
    [self.navigationController pushViewController:mainForm animated:YES];
}

/**跳转至离线界面
 */
- (void)jumpIntoOfflineForm{
    //    WJCUiMainForm *mainForm = [[WJCUiMainForm alloc] init];
    WJCCfgFilesList *cfgFilesForm = [[WJCCfgFilesList alloc] init];
    
    [self.navigationController pushViewController:cfgFilesForm animated:YES];
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

/** 结束界面下拉刷新，定时器0.5s后结束
 */
- (void)endRefresh{
    
    [self.refreshControl endRefreshing];
    
}
- (void)stopLoading{
//    [self.loadingView hideLoadingView]; wjc20180524
    [LCLoadingHUD hideInKeyWindow];
}
#pragma mark - WJCCloudDownFileDelegate 参数下载代理返回方法
static float progress = 0.0f;
- (void)downLoadCfgFileResult:(Boolean)rResult downResult:(WJCDownLoadResult)rDownResult cfgId:(int)rCfgId{
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
    
    if (rResult) {
        NSLog(@"成功");
        NSLog(@"%d",rDownResult);
        
        [hiDevice loadFileWithCfgId:rCfgId];
        [self performSelectorOnMainThread:@selector(jumpIntoMainControllerForm) withObject:nil waitUntilDone:NO];
    } else {
        NSLog(@"%d",rDownResult);
        NSString *showMessageCont = @"";
        switch (rDownResult) {
            case DOWNLOAD_TIMOUT:
                showMessageCont = [NSString stringWithFormat:@"网络超时，从云端下载参数文件%d失败，是否本地更新参数文件？",hiDevice.cfgId];
//                [self popDialogWithTittle:@"提示"  message:[NSString stringWithFormat:@"网络超时，从云端下载参数文件%d失败",hiDevice.cfgId]];
                break;
            case DOWNLOAD_NOTEXIST:{
                showMessageCont =  [NSString stringWithFormat:@"云端不存在参数文件%d，是否本地更新参数文件？",hiDevice.cfgId];
                break;
            }
            case DOWNLOAD_FAIL:
                showMessageCont =  [NSString stringWithFormat:@"从云端下载参数文件%d失败，是否本地更新参数文件？",hiDevice.cfgId];
//                [self popDialogWithTittle:@"提示"  message:[NSString stringWithFormat:@"从服务器下载参数文件%d失败",hiDevice.cfgId]];
                break;
            default:
                break;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:showMessageCont preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
        
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            hiDevice->theDelegate = self;
            progress = 0.0f;
            
            [SVProgressHUD showProgress:0 status:@"Loading"];
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight]; //SVProgressHUDStyleLight SVProgressHUDStyleDark
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];//SVProgressHUDMaskTypeBlack SVProgressHUDMaskTypeGradient
            //                    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
            [self.view setUserInteractionEnabled:NO];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //                        [hiDevice performSelectorOnMainThread:@selector(updateCfgFile) withObject:nil waitUntilDone:NO];
                [hiDevice updateCfgFile];
            });
            
        }];
        [alert addAction:okAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }]];
        
        NSLog(@"thread:%@",[NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
           // UI更新代码
            NSLog(@"thread:%@",[NSThread currentThread]);
            [self presentViewController:alert animated:YES completion:nil];
        });
       
        
    }
    
    
}
- (void)increaseProgress {
    /*
    progress += 0.005f;

    
    NSLog(@"%@",[NSThread currentThread]);
    if(progress < 1.0f){
        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"Loading%.2f%%",progress*100]];
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1f];
    } else {
        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"Loading100%%",progress*100]];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
        [self.view setUserInteractionEnabled:YES];
//        if (self.activityCount > 1) {
//            [self performSelector:@selector(popActivity) withObject:nil afterDelay:0.4f];
//        } else {
//            [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4f];
//        }
    }
     */
}

- (void)dismiss {
    [SVProgressHUD dismiss];
    [self.view setUserInteractionEnabled:YES];
//    self.activityCount = 0;
}
#pragma mark - update参数文件
-(void)updateCfgFileResult:(Boolean)rResult updateState:(WJCUpdateState)rUpdateState updateInfo:(NSString *)rUpdateStr updateProgress:(float)rUpdateProgress{
    
    if (rResult) {
        
        switch (rUpdateState) {
            case UPDATE_SUCC:{
                NSLog(@"%@",[NSThread currentThread]);
                [SVProgressHUD showProgress:rUpdateProgress status:rUpdateStr];
                [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(jumpIntoMainControllerForm) withObject:nil waitUntilDone:NO];
                break;
            }
            case UPDATE_UPDATING:{
                [SVProgressHUD showProgress:rUpdateProgress status:rUpdateStr];
                break;
            }
            default:
                break;
        }
    } else {
        NSLog(@"%@",[NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
           // UI更新代码
            [self popDialogWithTittle:@"提示" message:rUpdateStr];
        });
        
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:NO];

    }
}
#pragma mark - UDP发送接收动作
/** UDP发送指令
 */
- (void)sendSearchCommand{
    
    
    //清空接收缓存
    //互斥锁
    @synchronized(self){
        [self.wifiDevice removeAllObjects];
    }
    
            NSLog(@"thread:%@",[NSThread currentThread]);
    //界面清空
    //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
       // UI更新代码

        [self.tableView reloadData];
    });
    //创建udp，绑定本地端口，开启接收
    NSError *error = nil;
//    if (_udpSocketT == nil)
    {
        dispatch_queue_t testQueue = dispatch_queue_create("udpRec", DISPATCH_QUEUE_CONCURRENT);
        _udpSocketT = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:testQueue];
        [_udpSocketT bindToPort:400 error:&error];
        [_udpSocketT enableBroadcast:YES error:&error];
        [_udpSocketT beginReceiving:&error];
    }
    
    
    
    //udp发送
    NSString *msg = @"www.usr.cn";
    NSString *broadcastIp = [WJCDeviceFinder getBroadcastAddr];
    if ([broadcastIp isEqualToString:@""]) {
        
    } else {
        [_udpSocketT sendData:[msg dataUsingEncoding:NSUTF8StringEncoding] toHost:broadcastIp port:48899 withTimeout:-1 tag:1];
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

/** udp接收线程
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg) {
        
        NSArray *tempA = [msg componentsSeparatedByString:@","];
        if (tempA.count == 4) {
            WJCWifiDeviceInfo *tempDev = [[WJCWifiDeviceInfo alloc] init];
            tempDev.ip = tempA[0];
            tempDev.macIp = tempA[1];
            tempDev.name = tempA[2];
            tempDev.softwareVer = tempA[3];
            if ([tempA[0] isEqualToString:@""]) {
                
            } else {
                Boolean isSame = NO;
                for (int i=0; i<_wifiDevice.count; i++) {
                    if ([_wifiDevice[i].ip isEqualToString:tempA[0]]) {
                        isSame = YES;
                        break;
                    }
                }
                if (isSame) {
                    
                } else {
                    @synchronized(self){
                    [_wifiDevice addObject:tempDev];
                    }
                }
                
            }
            NSLog(@" 当前线程  %@",[NSThread currentThread]);
            [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
//            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        
        
        //        [_udpSocketT beginReceiving:nil];
        //        NSLog(@"RECV:%@",msg);
    }
}

@end
