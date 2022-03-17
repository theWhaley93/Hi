//
//  WJCArrayParaTable.m
//  Hi
//
//  Created by apple on 2018/4/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCArrayParaTable.h"
#import "WJCArrayParaCell.h"
#import "WJCUiParaEditor.h"
#import "WJCWorkllistParaEditor.h"

typedef enum{
    WJCArrayTableTypeNormal, WJCArrayTableTypeWorklist
} WJCArrayTableType;

@interface WJCArrayParaTable ()<WJCArrayParaClickDelegate>{
    WJCHiCommunicator *hiComm;
    Boolean isOffline;
    WJCDescDealer *descDealer;  //参数描述
    WJCOneParameter *nowPara;  //当前编辑的参数
    int paraSubindex;
    
    WJCArrayTableType arrayTypeMode;
    NSThread *readThread;
    NSString * paraName;
    NSTimer *uiTimer;
    
    //worklistitem
    WJCHiWorklistItem *nowWorklistItem;
    WJCDevice *nowDevice;
}


@end

@implementation WJCArrayParaTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",paraName,nowPara.lDescribe];
    
    //清除多余cell
    
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 48;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    if (isOffline) {
        
    } else {
        readThread = [[NSThread alloc] initWithTarget:self selector:@selector(readDataSetParaThread) object:nil];
        [readThread start];
        uiTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshUi) userInfo:nil repeats:YES];
        [uiTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (isOffline) {
        
    } else {
        [uiTimer setFireDate:[NSDate distantFuture]];
        [readThread cancel];
        [uiTimer invalidate];
        uiTimer = nil;
    }
    
}

- (instancetype)initWithDescDealer:(WJCDescDealer *)rDescDealer withPara:(WJCOneParameter *)rPara withComm:(WJCHiCommunicator *)rHiCom withIsOffline:(Boolean)rIsOffline withParaName:(NSString *)rName withSubindex:(int)rSubindex{
    if (self = [super init]) {
        descDealer = rDescDealer;
        nowPara = rPara;
        hiComm = rHiCom;
        paraName = rName;
        isOffline = rIsOffline;
        paraSubindex = rSubindex;

        arrayTypeMode = WJCArrayTableTypeNormal;
    }
    return self;
}
- (instancetype)initWithWorklistItem:(WJCHiWorklistItem *)rWorklistItem withHiDevice:(WJCDevice *)rDevice withParaName:(NSString *)rName withSubindex:(int) rSubindex{
    if (self = [super init]) {
        nowDevice = rDevice;
        nowWorklistItem = rWorklistItem;
        descDealer = rDevice.descDealer;
        nowPara = rWorklistItem.nowPara;
        hiComm = rDevice.hiCom;
        paraName = rName;
        isOffline = rDevice.isOffline;
        paraSubindex = rSubindex;
        arrayTypeMode = WJCArrayTableTypeWorklist;
    }
    return self;
}
#pragma mark - 线程

- (void)refreshUi{
    [self.tableView reloadData];
}
- (void)readDataSetParaThread{
    while (1) {

        NSString *recStr = @"";
        for (int i=0; i<nowPara.arrayCount; i++) {
            
            recStr = [hiComm readArrayDataWithIndex:nowPara.index withSubindex:paraSubindex withArrayIndex:i];
            
            [nowPara setValHexWithSubindex:paraSubindex withArrayIndex:i val:recStr];
            
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
                
            }
            
            [NSThread sleepForTimeInterval:0.03f];
            
        }
            
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
            
        }
        
        [NSThread sleepForTimeInterval:0.02f];
        
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return (nowPara->arrayLength+1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WJCArrayParaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArrayCell"];

    if (cell == nil) {
        cell = [WJCArrayParaCell arrayParaWithTableView:tableView];
    }
        switch (arrayTypeMode) {
            case WJCArrayTableTypeNormal:{
                [cell loadCellInfoWithPara:nowPara withRow:indexPath.row withSubindex:paraSubindex withDesc:descDealer withDelegate:self];
                break;
            }
            case WJCArrayTableTypeWorklist:{
                [cell loadCellInfoWithWorklistItem:nowWorklistItem withRow:indexPath.row withSubindex:paraSubindex withDesc:descDealer withDelegate:self];
                break;
            }
        };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell分隔线
//        [cell setSeparatorInset:UIEdgeInsetsZero];
    
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0) {
        
        for (int i=0; i<nowPara->arrayWidth; i++) {
            UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake((38+8+8*i), 2, 50, 40)];
//            tempB.titleLabel.text = [NSString stringWithFormat:@"列%d",i];
            [tempB setTitle:@"列%d" forState:UIControlStateNormal];
//            [button setTitle:[NSString stringWithFormat:@"确定写入"] forState:UIControlStateNormal];
            [cell addSubview:tempB];
        }

    
        
    } else {
        
        UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake(8, 2, 50, 40)];
        tempB.titleLabel.text = [NSString stringWithFormat:@"行%ld",indexPath.row-1];
        
        [cell addSubview:tempB];
        
        for (int i=0; i<nowPara->arrayWidth; i++) {
            UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake((38+8+8*i), 2, 50, 40)];
            
            NSInteger arrI = nowPara->arrayWidth * (indexPath.row - 1) + i;
//            tempB.titleLabel.text = [nowPara showParaDesc:[nowPara valHexWithSubindex:paraSubindex withArrayIndex:arrI] descD:descDealer];
            [tempB setTitle:[nowPara showParaDesc:[nowPara valHexWithSubindex:paraSubindex withArrayIndex:arrI]  descD:descDealer] forState:UIControlStateNormal];
            [cell addSubview:tempB];
        }
        
    }
    */
    
//    cell.textLabel.text = [nowPara showParaDesc:[nowPara valHexWithSubindex:paraSubindex withArrayIndex:indexPath.row] descD:descDealer];//[NSString stringWithFormat:@"子索引%@",_onepa];
    // Configure the cell...
    
    return cell;
}

- (void)clickWithRow:(int)rRow withIndex:(int)rIndex{
    switch (arrayTypeMode) {
        case WJCArrayTableTypeNormal:{
            WJCUiParaEditor *paraView = [[WJCUiParaEditor alloc] initWitPara:nowPara withName:paraName withDescDealer:descDealer withSubindex:paraSubindex withArrayIndex:rIndex withCom:hiComm withOffline:isOffline];
            [self.navigationController pushViewController:paraView animated:YES];
            break;
        }
        case WJCArrayTableTypeWorklist:{
            WJCWorkllistParaEditor *tempWorklist = [[WJCWorkllistParaEditor alloc] initWithWorklistItem:nowWorklistItem withHiDevice:nowDevice withSubindex:paraSubindex withArrayIndex:rIndex];
            [self.navigationController pushViewController:tempWorklist animated:YES];
            break;
        }
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
