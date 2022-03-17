//
//  WJCFilesViewController.m
//  Hi
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCFilesViewController.h"
#import "WJCFilesManger.h"
#import "ZKSegment.h"
#import "WJCDevice.h"
//#import "LoadingViewForOC.h"
#import "LCLoadingHUD.h"

//文件浏览器的模式，本地和云端
typedef enum {
    ListViewLocal, ListViewCloud
    
}ListViewMode;


@interface WJCFilesViewController ()<UITableViewDataSource,UITableViewDelegate,WJCCloudDownFileDelegate>{
    WJCLocalFilesManger * hiFileManger;
    WJCCloudFilesManger *hiCloudFileManger;
    ListViewMode nowListMode;
    WJCDevice *nowDevice;
    float t1,t2,t3,t4,t5;
}
//@property (nonatomic,strong)   WJCDevice *nowDevice;  //hi device
@property (nonatomic, strong)ZKSegment *zkSegment;
@property (nonatomic,assign)ZKSegmentStyle zkSegmentStyle;
@property (nonatomic,strong)  UITableView *fileTable;  //
//@property (nonatomic,weak)  LoadingViewForOC *loadingView;  //wjc20180524

@property (nonatomic,strong)  WJCCloudFileItem *nowDownloadFile;  //


@end

@implementation WJCFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    UINavigationController *nav = [[UINavigationController alloc] init];
    [self initFileManger];
    
    self.navigationItem.title = @"文件浏览";
    /* 可用方式1
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton *button = [[UIButton alloc] initWithFrame:contentView.bounds];
    [button setImage:[UIImage imageNamed:@"if_unfold"] forState:UIControlStateNormal];
    [contentView addSubview:button];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:contentView];
    self.navigationItem.rightBarButtonItem = item2;
    */
    /* 可用方式2
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_more3"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = item2;
    */
//    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    testButton.frame = CGRectMake(0, 0, 30, 30);
//    [testButton setImage:[UIImage imageNamed:@"if_more"] forState:UIControlStateNormal];
//        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:testButton];
//        self.navigationItem.rightBarButtonItem = item2;
//    testButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [[UIImage imageNamed:@"if_unfold"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    [testButton setBackgroundImage:[UIImage imageNamed:@"if_unfold"]  forState:UIControlStateNormal];
//    testButton.layer.masksToBounds = YES;
//    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_unfold"] style:UIBarButtonItemStylePlain target:self action:nil];

//    UIBarButtonItem *navigationSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    navigationSeperator.width = -20;
//    self.navigationItem.rightBarButtonItems = @[item2,navigationSeperator];
    
    
    //当前模式切换
    nowListMode = ListViewCloud;
    
    //左右栏切换
    self.zkSegmentStyle = ZKSegmentRectangleStyle;
    [self resetSegment];
    
    t4 = self.zkSegment.frame.size.height;
    
    //tableview显示
    _fileTable = [[UITableView alloc] initWithFrame:CGRectMake(0, t4+t1+t2-t3, self.view.frame.size.width, self.view.bounds.size.height-(t4+t1+t2-t3))];
    [self.view addSubview:self.fileTable];
    
    _fileTable.dataSource = self;
    _fileTable.delegate = self;
    
    //清除多余cell
    _fileTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //    _fileTable.rowHeight = 55;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.fileTable.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithDevice:(WJCDevice *) rDevice{
    if (self = [super init]) {
        nowDevice = rDevice;
    }
    return self;
}
- (void)stopLoading{
//    [self.loadingView hideLoadingView];
    [LCLoadingHUD hideInKeyWindow];
    
}

- (void)jumpToFileList{
    switch (_nowDownloadFile.fileType) {
        case WJCFileTypeWorklist:         //文件类型
            
            [nowDevice.projectManger loadWithWorklistFilePath:_nowDownloadFile.dowloadFilePath];

            break;
        case WJCFileTypeChart:         //文件类型

            [nowDevice.projectManger loadWithChartFilePath:_nowDownloadFile.dowloadFilePath];

            break;
        case WJCFileTypeProject:         //文件类型

            [nowDevice.projectManger loadWithProjectFilePath:_nowDownloadFile.dowloadFilePath];


            break;
    }
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
}
#pragma mark- 左右栏切换
- (void)resetSegment {
    if (self.zkSegment) {
        [self.zkSegment removeFromSuperview];
    }
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    t1 = self.navigationController.navigationBar.frame.size.height;
    t2 = statusBarFrame.size.height;
    t3 = 0;
    if(t2==40)
        t3=20;
    self.zkSegment = [ZKSegment
                      zk_segmentWithFrame:CGRectMake(0, t1+t2-t3, self.view.bounds.size.width, 45)
                      style:self.zkSegmentStyle];
    // 可手动设置各种颜色；
    // 如不设置则使用默认颜色
    self.zkSegment.zk_itemDefaultColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
    switch (self.zkSegmentStyle) {
        case ZKSegmentLineStyle:
            self.zkSegment.zk_itemSelectedColor = [UIColor colorWithRed:202 / 255.0 green:51 / 255.0 blue:54 / 255.0 alpha:1];
            break;
        case ZKSegmentRectangleStyle:
            self.zkSegment.zk_itemSelectedColor = [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:250 / 255.0 alpha:1];
            break;
        case ZKSegmentTextStyle:
            self.zkSegment.zk_itemSelectedColor = [UIColor colorWithRed:202 / 255.0 green:51 / 255.0 blue:54 / 255.0 alpha:1];
            break;
    }
    self.zkSegment.zk_itemStyleSelectedColor = [UIColor colorWithRed:202 / 255.0 green:51 / 255.0 blue:54 / 255.0 alpha:1];
    self.zkSegment.zk_backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];
    //    __weak typeof(self) weakSelf = self;
    self.zkSegment.zk_itemClickBlock = ^(NSString *itemName, NSInteger itemIndex) {
        //        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        //左右切换动作
        switch (nowListMode) {
            case ListViewLocal:
                nowListMode = ListViewCloud;
                if (hiCloudFileManger.level == 0) {
                    [NSThread detachNewThreadSelector:@selector(loadCloudDir) toTarget:self withObject:nil];
                } else if (hiCloudFileManger.level == 1) {
                    
                }
                [self.fileTable reloadData];
                break;
                
            case ListViewCloud:
                nowListMode = ListViewLocal;
                [hiFileManger loadLocalFilesFromDir:hiFileManger.nowLocalDir];
                [self.fileTable reloadData];
                break;
        }
        
        
        
        
    };
    [self.zkSegment zk_setItems:@[ @"本地目录", @"云端目录" ]];
    [self.view addSubview:self.zkSegment];
}

#pragma mark- tableview代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (nowListMode) {
        case ListViewLocal:
            return hiFileManger.localFileList.count;
            break;
            
        case ListViewCloud:{
            NSInteger resultN = 0;
            if (hiCloudFileManger.level == 0) {
                resultN = hiCloudFileManger.dirList.count;
            } else if (hiCloudFileManger.level == 1) {
                resultN = hiCloudFileManger.fileList.count;
            }
            return resultN;
            break;
        }
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    
    switch (nowListMode) {
        case ListViewLocal:{
            WJCLoaclFileItem * tempFile = hiFileManger.localFileList[indexPath.row];
            if (tempFile.isReturn) {
//                cell.imageView.image = [UIImage imageNamed:@"if_sback"];
                cell.imageView.image = [UIImage imageNamed:@"if_hand_return"];
                cell.textLabel.text = @"";//@"返回上一目录";
            } else {
                //        if (tempFile.isDir) {
                //            cell.imageView.image = [UIImage imageNamed:@"if_sdirectory"];
                //        } else {
                //            cell.imageView.image = [UIImage imageNamed:@"if_sfile"];
                //        }
                NSString *detailT = @"";
                switch (tempFile.fileType) {
                    case WJCFileTypeDirectory:
//                        cell.imageView.image = [UIImage imageNamed:@"if_sdirectory"];
                        cell.imageView.image = [UIImage imageNamed:@"if_hand_dir"];
                        detailT = @"文件夹";
                        break;
                    case WJCFileTypeWorklist:
//                        cell.imageView.image = [UIImage imageNamed:@"if_sfile"];
                        cell.imageView.image = [UIImage imageNamed:@"if_hand_worklist"];
                        //                [NSByteCountFormatter stringFromByteCount:tempFile.fileSize countStyle:NSByteCountFormatterCountStyleFile];
                        detailT = [detailT stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"Worklist文件",@"  ",[NSByteCountFormatter stringFromByteCount:tempFile.fileSize countStyle:NSByteCountFormatterCountStyleBinary]]];//@"Worklist文件";
                        break;
                    case WJCFileTypeChart:
//                        cell.imageView.image = [UIImage imageNamed:@"if_sfile"];
                        cell.imageView.image = [UIImage imageNamed:@"if_hand_chart"];
                        detailT = [detailT stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"曲线文件",@"  ",[NSByteCountFormatter stringFromByteCount:tempFile.fileSize countStyle:NSByteCountFormatterCountStyleBinary]]];//@"曲线文件夹";
                        break;
                    case WJCFileTypeProject:
//                        cell.imageView.image = [UIImage imageNamed:@"if_sproject"];
                        cell.imageView.image = [UIImage imageNamed:@"if_hand_project"];
                        detailT = [detailT stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"工程文件",@"  ",[NSByteCountFormatter stringFromByteCount:tempFile.fileSize countStyle:NSByteCountFormatterCountStyleBinary]]];//@"工程文件";
                        break;
                }
                cell.textLabel.text = tempFile.fileName;
                cell.detailTextLabel.text = detailT;
            }
            break;
        }
            //云端目录
        case ListViewCloud:{
            
            if (hiCloudFileManger.level == 0) {
                if (indexPath.row < hiCloudFileManger.dirList.count) {
                    cell.imageView.image = [UIImage imageNamed:@"if_sdirectory"];
                    cell.textLabel.text = hiCloudFileManger.dirList[indexPath.row].dirName;
                    cell.detailTextLabel.text = @"文件夹";
                }

                
            } else if (hiCloudFileManger.level == 1) {
                
                WJCCloudFileItem * tempCloudFile = hiCloudFileManger.fileList[indexPath.row];
                if (tempCloudFile.isReturn) {
//                    cell.imageView.image = [UIImage imageNamed:@"if_sback"];
                    cell.imageView.image = [UIImage imageNamed:@"if_hand_return"];
                    cell.textLabel.text = @"";//@"返回上一目录";
                } else {
                    
                    NSString *detailT = @"";
                    switch (tempCloudFile.fileType) {
                        case WJCFileTypeDirectory:
//                            cell.imageView.image = [UIImage imageNamed:@"if_sdirectory"];
                            cell.imageView.image = [UIImage imageNamed:@"if_hand_return"];
                            detailT = @"文件夹";
                            break;
                        case WJCFileTypeWorklist:
//                            cell.imageView.image = [UIImage imageNamed:@"if_sfile"];
                            cell.imageView.image = [UIImage imageNamed:@"if_hand_worklist"];
                            //                [NSByteCountFormatter stringFromByteCount:tempFile.fileSize countStyle:NSByteCountFormatterCountStyleFile];
                            detailT = [detailT stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"Worklist文件",@"  ",[NSByteCountFormatter stringFromByteCount:[tempCloudFile.fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleBinary]]];//@"Worklist文件";
                            break;
                        case WJCFileTypeChart:
//                            cell.imageView.image = [UIImage imageNamed:@"if_sfile"];
                            cell.imageView.image = [UIImage imageNamed:@"if_hand_chart"];
                            detailT = [detailT stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"曲线文件",@"  ",[NSByteCountFormatter stringFromByteCount:[tempCloudFile.fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleBinary]]];//@"曲线文件夹";
                            break;
                        case WJCFileTypeProject:
//                            cell.imageView.image = [UIImage imageNamed:@"if_sproject"];
                            cell.imageView.image = [UIImage imageNamed:@"if_hand_project"];
                            detailT = [detailT stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"工程文件",@"  ",[NSByteCountFormatter stringFromByteCount:[tempCloudFile.fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleBinary]]];//@"工程文件";
                            break;
                    }
                    cell.textLabel.text = tempCloudFile.fileName;
                    cell.detailTextLabel.text = detailT;
                }
                
                
            }
            
            
            break;
        }
    }
    
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (nowListMode) {
        case ListViewLocal:{
            WJCLoaclFileItem * tempFile = hiFileManger.localFileList[indexPath.row];
            if (tempFile.isReturn) {
                [self popDialogWithTittle:@"提示" message:@"请重新选择要删除的文件!"];
            } else {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要删除选择的文件?" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
                
                UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    //确定删除
                    NSFileManager *fileManger = [NSFileManager defaultManager];
                    if ([fileManger removeItemAtPath:tempFile.filePath error:NULL]) {
                        NSLog(@"删除文件成功");
                        [hiFileManger.localFileList removeObjectAtIndex:indexPath.row];
                        [_fileTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    } else {
                        NSLog(@"删除文件失败");
                    }
                    
                }];
                [alert addAction:okAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                    //取消删除动作
                    
                }]];
                
                
                [self presentViewController:alert animated:YES completion:nil];
//                switch (tempFile.fileType) {
//                    case WJCFileTypeDirectory:
//
//                        break;
//                    case WJCFileTypeWorklist:
//
//                        break;
//                    case WJCFileTypeChart:
//
//                        break;
//                    case WJCFileTypeProject:
//
//                        break;
//                }

            }
            break;
        }
        case ListViewCloud:{
            [self popDialogWithTittle:@"提示" message:@"云端目录无法删除文件!"];
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (nowListMode) {
        case ListViewLocal:{
            WJCLoaclFileItem * tempFile = hiFileManger.localFileList[indexPath.row];
            
            if (tempFile.isReturn) {
                [hiFileManger loadLocalFilesFromDir:tempFile.fileDir];
                [self.fileTable reloadData];
            } else {
                if (tempFile.isDir) {
                    [hiFileManger loadLocalFilesFromDir:tempFile.filePath];
                    [self.fileTable reloadData];
                } else {
                    
//                    [self popDialogWithTittle:@"提示" message:[NSString stringWithFormat:@"%@%@",@"打开",tempFile.fileName]];
                    switch (tempFile.fileType) {
                        case WJCFileTypeWorklist:         //文件类型

                            [nowDevice.projectManger loadWithWorklistFilePath:tempFile.filePath];
                            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
                            break;
                        case WJCFileTypeChart:         //文件类型

                            [nowDevice.projectManger loadWithChartFilePath:tempFile.filePath];
                            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
                            break;
                        case WJCFileTypeProject:         //文件类型
                            if ((nowDevice.projectManger.worklistCount>0) || (nowDevice.projectManger.chartCount>0)) {
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开该工程会覆盖掉当前所有已载入的文件，是否继续" preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                    [nowDevice.projectManger loadWithProjectFilePath:tempFile.filePath];
                                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
                                }];

                                UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                    
                                }];
                                [alert addAction:okAlert];
                                [alert addAction:cancelAlert];
                                [self presentViewController:alert animated:YES completion:nil];

                            } else {
                              [nowDevice.projectManger loadWithProjectFilePath:tempFile.filePath];
                              [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] animated:YES];
                            }
                            
                            break;
                    }
                    

                    
                }
            }
            break;
        }
        case ListViewCloud:{
            
            if (hiCloudFileManger.level == 0) {
                [NSThread detachNewThreadSelector:@selector(loadCloudFileWithId:) toTarget:self withObject:hiCloudFileManger.dirList[indexPath.row].dirId];
                
            } else if (hiCloudFileManger.level == 1) {
                _nowDownloadFile = hiCloudFileManger.fileList[indexPath.row];

                if (_nowDownloadFile.isReturn) {
                    [NSThread detachNewThreadSelector:@selector(loadCloudDir) toTarget:self withObject:nil];
                } else {
                    switch (_nowDownloadFile.fileType) {
                        case WJCFileTypeWorklist:case WJCFileTypeChart:{
//                                _loadingView = [LoadingViewForOC showLoadingWithWindow];wjc20180524
                                [LCLoadingHUD showLoading:@"正在载入中..."];
                                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                    [hiCloudFileManger downloadCloudFileWithFileItem:_nowDownloadFile];
                                });
                            break;
                        }
                        case WJCFileTypeProject:{
                            if ((nowDevice.projectManger.worklistCount>0) || (nowDevice.projectManger.chartCount>0)) {
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开该工程会覆盖掉当前所有已载入的文件，是否继续" preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                        //确认动作
//                                        _loadingView = [LoadingViewForOC showLoadingWithWindow];wjc20180524
                                        [LCLoadingHUD showLoading:@"正在载入中..."];
                                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                            [hiCloudFileManger downloadCloudFileWithFileItem:_nowDownloadFile];
                                        });
                                    }];
                                
                                    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                        
                                    }];
                                    [alert addAction:okAlert];
                                    [alert addAction:cancelAlert];
                                    [self presentViewController:alert animated:YES completion:nil];
                            } else {
//                                _loadingView = [LoadingViewForOC showLoadingWithWindow];wjc20180524
                                [LCLoadingHUD showLoading:@"正在载入中..."];
                                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                    [hiCloudFileManger downloadCloudFileWithFileItem:_nowDownloadFile];
                                });
                            }
                            break;
                        }
                    }

                    
                    
                    
                }
            }
            
            break;
        }
    }
    
    
}

#pragma mark- 弹出提示框
- (void)popDialogWithTittle:(NSString *)rTittle message:(NSString *)rMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:rTittle message:rMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [alert addAction:okAlert];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)popNetError{
    [self popDialogWithTittle:@"提示" message:@"无法获取云端文件，请检查网络连接"];
}



#pragma mark- 文件管理器动作
- (void)initFileManger{
    //初始化本地文件管理器
    NSString *docuDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    hiFileManger = [[WJCLocalFilesManger alloc] initWithRootLocalDir: docuDir];
    
    //初始化云端文件管理器
    hiCloudFileManger = [[WJCCloudFilesManger alloc] initWithDelegate:self];

}


- (void)loadCloudDir{
    
    if ([hiCloudFileManger getDirList]){
        hiCloudFileManger.level = 0;
    } else {
        [self performSelectorOnMainThread:@selector(popNetError) withObject:nil waitUntilDone:NO];
    }
    [self.fileTable performSelectorOnMainThread:@selector(reloadData) withObject:self waitUntilDone:NO];
}

- (void)loadCloudFileWithId:(NSString *)rId{
    if ([hiCloudFileManger getFileListWithDirId:rId]) {
        hiCloudFileManger.level = 1;
    } else {
        [self performSelectorOnMainThread:@selector(popNetError) withObject:nil waitUntilDone:NO];
    }
    [self.fileTable performSelectorOnMainThread:@selector(reloadData) withObject:self waitUntilDone:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark- 下载delegate
- (void)downLoadCfgFileResult:(Boolean)rResult downResult:(WJCDownLoadResult)rDownResult cfgId:(int)rCfgId{
    if (rResult) {
        NSLog(@"成功");
        NSLog(@"%d",rDownResult);
        
        [self performSelectorOnMainThread:@selector(jumpToFileList) withObject:nil waitUntilDone:NO];
    } else {
        NSLog(@"%d",rDownResult);
        [self popDialogWithTittle:@"提示"  message:@"下载失败" ];
        
    }
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
}
@end
