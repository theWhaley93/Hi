//
//  WJCWorklistController.m
//  Hi
//
//  Created by apple on 2018/4/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistController.h"
#import "WJCWorklistViewCell.h"
#import "YCXMenu.h"
#import "WJCWorkllistParaEditor.h"
#import "WJCWorklistEditorView.h"
#import "WJCWorklistDataSetController.h"
#import "WJCArrayParaTable.h"
#import "LCLoadingHUD.h"



@interface WJCWorklistController ()<WJCDownloadWorklistDelegate>{
    Boolean isOffline;
    WJCWorklistOperate nowWorklistOperate;
    int uploadTimes;
}

@property (nonatomic,strong)  NSThread *nowThread;  //

@property (nonatomic,strong)  NSTimer *uiTimer;  //
@property (nonatomic , strong) NSMutableArray *items;   //bar button显示菜单：


@end

@implementation WJCWorklistController
@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRightButtons];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = _nowWorklist.name;
    
    //清除多余cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 66.5;
    
    if (isOffline) {
        
    } else {
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setTable) userInfo:nil repeats:YES];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    if (isOffline) {
        [self.tableView reloadData];
    } else {
        _nowThread = [[NSThread alloc] initWithTarget:self selector:@selector(readThread) object:nil];
        [_nowThread start];
        
        [_uiTimer setFireDate:[NSDate distantPast]];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    if (isOffline) {
        
    } else {
        [_uiTimer setFireDate:[NSDate distantFuture]];
        [_nowThread cancel];
    }
}
#pragma mark - 界面操作
- (void)setTable{
    [self.tableView reloadData];
}

- (void)startWorklistOperate:(NSString *)rOperateInfo{
    [LCLoadingHUD showLoading:rOperateInfo];
}

- (void)endWorklistOperate{
    [LCLoadingHUD hideInKeyWindow];
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
- (void)uploadSuccess{
    [self popDialogWithTittle:@"提示" message:@"上传参数完成"];
}
#pragma mark - 菜单栏内容
- (void)setRightButtons{
//    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenu)];
    UIBarButtonItem *barMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"if_more3"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = barMenu;
}

- (void)showMenu{
    [YCXMenu setTintColor:[UIColor darkGrayColor]];
    [YCXMenu setSelectedColor:[UIColor lightGrayColor]];
    if ([YCXMenu isShow]){
        [YCXMenu dismissMenu];
    } else {
        [YCXMenu showMenuInView:self.tableView fromRect:CGRectMake(self.view.frame.size.width - 50, self.navigationController.navigationBar.frame.size.height+22, 50, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
            
            //点击右上角菜单
            switch (index) {
                case 0:{
                    WJCWorklistEditorView *worklistEditor = [[WJCWorklistEditorView alloc] initWithHiPara:_nowDevice.paras withWorklist:_nowWorklist];
                    [self.navigationController pushViewController:worklistEditor animated:YES];

                    break;
                }
                case 1:
                    nowWorklistOperate = WJCWorklistOperateDownload;
                    [self startWorklistOperate:@"正在下载参数至驱动器..."];
                    break;
                case 2:
                    nowWorklistOperate = WJCWorklistOperateUpload;
                    uploadTimes = 0;
                    [self startWorklistOperate:@"正在从驱动器上传参数..."];
                    break;
                case 3:{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要保存的文件名" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
                    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.text = _nowWorklist.name;
                    }];
                    
                    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        //保存文件
                        NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                        NSString *saveName = [NSString stringWithFormat:@"%@%@%@%@",dirPath,@"/",alert.textFields[0].text,@".htnwk"];//alert.textFields[0].text;
//                        NSString *savePath = [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],@"/AddressListFiles/CFGID98.plst"];
                        NSString *contentStr = [_nowWorklist worklistToString];
                        [contentStr writeToFile:saveName atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:NULL];
                        

                        
                        
                        
                    }];
                    [alert addAction:okAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                        
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case 4:{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入要创建的worklist名称" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert];
                    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.text = _nowWorklist.name;
                    }];
                    
                    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        //修改worklistname
                        _nowWorklist.name = alert.textFields[0].text;
                        self.title = _nowWorklist.name;
                        
                        
                        
                    }];
                    [alert addAction:okAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                        
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
            }
            
//            NSLog(@"%@",item);
        }];
    }
}

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
                    [YCXMenuItem menuItem:@"编辑参数"
                                    image:nil
                                      tag:100
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"下载参数"
                                    image:nil
                                      tag:101
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"上传参数"
                                    image:nil
                                      tag:101
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"保存文件"
                                    image:nil
                                      tag:102
                                 userInfo:@{@"title":@"Menu"}],
                    [YCXMenuItem menuItem:@"修改worklist名"
                                    image:nil
                                      tag:102
                                 userInfo:@{@"title":@"Menu"}]
                    ] mutableCopy];
    }
    return _items;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
}

#pragma mark - Table view data source/delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return _nowWorklist.item.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WJCWorklistViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorklistCell"];
    if (cell == nil) {
        cell = [WJCWorklistViewCell worklistViewCellWithTableView:tableView];


    }
    [cell loadWorklistItem:_nowWorklist.item[indexPath.row] withDesc:_nowDevice.descDealer];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    //    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WJCHiWorklistItem *tempPara = _nowWorklist.item[indexPath.row];//hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index];
//    NSString *paraName = hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->abbreviativeName;
    
    if ((tempPara.nowPara.isArray) && (tempPara.nowPara.isDataSet)) {
        WJCWorklistDataSetController *tempDataSetWorklist = [[WJCWorklistDataSetController alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice];
        [self.navigationController pushViewController:tempDataSetWorklist animated:YES];
        
    } else if ((!tempPara.nowPara.isArray) && (tempPara.nowPara.isDataSet)) {
        
        WJCWorklistDataSetController *tempDataSetWorklist = [[WJCWorklistDataSetController alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice];
        [self.navigationController pushViewController:tempDataSetWorklist animated:YES];
        
        
    } else if ((tempPara.nowPara.isArray) && (!tempPara.nowPara.isDataSet)) {
        
        WJCArrayParaTable *tempT = [[WJCArrayParaTable alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice withParaName:tempPara.sName withSubindex:0];
        [self.navigationController pushViewController:tempT animated:YES];
        
    } else if ((!tempPara.nowPara.isArray) && (!tempPara.nowPara.isDataSet)) {
        
        WJCWorkllistParaEditor *tempWorklist = [[WJCWorkllistParaEditor alloc] initWithWorklistItem:tempPara withHiDevice:_nowDevice withSubindex:0 withArrayIndex:0];
        [self.navigationController pushViewController:tempWorklist animated:YES];
        
        
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
#pragma mark- 初始化
- (instancetype)initWithWorklist:(WJCHiWorklist*) rWorklist withDevice:(WJCDevice*)rDevice withIsOffline:(Boolean)rIsOffline{
    if (self = [super init]) {
        _nowWorklist = rWorklist;
        _nowWorklist.theDelegate = self;
        _nowDevice = rDevice;
        isOffline = rIsOffline;
        nowWorklistOperate = WJCWorklistOperateNone;
    }
    return self;

}

#pragma mark-线程操作
- (void)readThread{
    while (1) {
        for (int i=0; i<_nowWorklist.item.count; i++) {
            [_nowDevice.hiCom readWithPara:_nowWorklist.item[i].nowPara isArrayEnable:YES];
            [NSThread sleepForTimeInterval:0.02f];
            
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
                
            }
            
        }
        [self doWorklistOperate];
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
            
        }
    }
}
#pragma mark-上传下载操作
- (void)doWorklistOperate{

    switch (nowWorklistOperate) {
        case WJCWorklistOperateNone:
            
            break;
            
        case WJCWorklistOperateDownload:
            [_nowWorklist downloadSettingVals:_nowDevice.hiCom];
            nowWorklistOperate = WJCWorklistOperateNone;
            [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:NO];
            break;
        case WJCWorklistOperateUpload:
            
            [_nowWorklist onlineValsToSettingVals];

            if (uploadTimes>1) {
                [self performSelectorOnMainThread:@selector(endWorklistOperate) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(uploadSuccess) withObject:nil waitUntilDone:NO];
                nowWorklistOperate = WJCWorklistOperateNone;
            }
            uploadTimes += 1;
            break;
    }
}

- (void)downLoadWorklistResult:(Boolean)rResult failItem:(WJCHiWorklistItem *)rItem failString:(NSString *)rStr{
    if (rResult) {
        [self popDialogWithTittle:@"提示" message:@"下载参数完成"];
    } else {
        if (rItem == nil) {
            [self popDialogWithTittle:@"提示" message:rStr];
        } else {
            
            [self popDialogWithTittle:@"提示" message:[NSString stringWithFormat:@"%@参数下载失败",rItem.sName]];
        }
    }
}

@end
