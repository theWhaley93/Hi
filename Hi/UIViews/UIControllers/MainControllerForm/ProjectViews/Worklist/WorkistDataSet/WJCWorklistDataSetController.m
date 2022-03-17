//
//  WJCWorklistDataSetController.m
//  Hi
//
//  Created by apple on 2018/5/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorklistDataSetController.h"
#import "WJCWorklistDataSetCell.h"
#import "WJCWorkllistParaEditor.h"
#import "WJCArrayParaTable.h"

@interface WJCWorklistDataSetController (){
    NSThread *readThread;
}
@property (nonatomic,strong)  WJCDevice *nowHiDevice;  //传入的Hi device
@property (nonatomic,strong)  WJCHiWorklistItem *nowWorklistItem;  //

@property (nonatomic,strong)  NSTimer *uiTimer;  //
@end

@implementation WJCWorklistDataSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ %@",_nowWorklistItem.sName,_nowWorklistItem.nowPara.lDescribe];
    //清除多余cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 66.5;
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
- (instancetype)initWithWorklistItem:(WJCHiWorklistItem*)rItem withHiDevice:(WJCDevice*)rDevice{
    if (self = [super init]) {
        _nowHiDevice = rDevice;
        _nowWorklistItem = rItem;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    if (_nowHiDevice.isOffline) {
        
    } else {
        readThread = [[NSThread alloc] initWithTarget:self selector:@selector(readDataSetParaThread) object:nil];
        [readThread start];
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshUi) userInfo:nil repeats:YES];
        [_uiTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (_nowHiDevice.isOffline) {
        
    } else {
        [_uiTimer setFireDate:[NSDate distantFuture]];
        [readThread cancel];
        [_uiTimer invalidate];
        _uiTimer = nil;
    }
    
}
- (void)refreshUi{
    [self.tableView reloadData];
}

#pragma mark - 读取线程
- (void)readDataSetParaThread{
    while (1) {
        if (!_nowWorklistItem.nowPara.isArray) {
            NSString *recStr = @"";
            for (int i=0; i<2; i++) {
                if (_nowWorklistItem.nowPara.isString) {
                    recStr = [_nowHiDevice.hiCom readStringData:_nowWorklistItem.nowPara.index subindex:i];
                    
                    
                } else {
                    recStr = [_nowHiDevice.hiCom readData:_nowWorklistItem.nowPara.index subindex:i];
                }
                [_nowWorklistItem.nowPara setValHexWithSubindex:i withArrayIndex:0 val:recStr];
                
                if ([[NSThread currentThread] isCancelled]) {
                    [NSThread exit];
                    
                }
                
                [NSThread sleepForTimeInterval:0.02f];
                
            }
            
        } else {
            
        }
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
            
        }
        [NSThread sleepForTimeInterval:0.2f];
        
    }
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WJCWorklistDataSetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataSetWorklistCell"];
    if (cell == nil) {
        cell = [WJCWorklistDataSetCell worklistDataSetCellWithTableView:tableView];
        
        
    }
    [cell loadWithWorklistItem:_nowWorklistItem withDesc:_nowHiDevice.descDealer withSubindex:indexPath.row];
//    [cell loadWithWorklistItem:_nowWorklistItem withDesc:_nowHiDevice.descDealer withSubindex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    //    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_nowWorklistItem.nowPara.isArray) {
        
        WJCArrayParaTable *tempT = [[WJCArrayParaTable alloc] initWithWorklistItem:_nowWorklistItem withHiDevice:_nowHiDevice withParaName:_nowWorklistItem.sName withSubindex:indexPath.row];
        [self.navigationController pushViewController:tempT animated:YES];
        
    } else {
        WJCWorkllistParaEditor *tempWorklist = [[WJCWorkllistParaEditor alloc] initWithWorklistItem:_nowWorklistItem withHiDevice:_nowHiDevice withSubindex:indexPath.row withArrayIndex:0];
        [self.navigationController pushViewController:tempWorklist animated:YES];
    }

    
}
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
