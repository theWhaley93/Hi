//
//  WJCDatasetParaTable.m
//  Hi
//
//  Created by apple on 2018/4/2.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDatasetParaTable.h"
#import "WJCUiParaEditor.h"
#import "WJCArrayParaTable.h"

@interface WJCDatasetParaTable (){
    NSThread *readThread;
    NSString * paraName;
}

@property (nonatomic,strong)  NSTimer *uiTimer;  //

@end

@implementation WJCDatasetParaTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",paraName,_nowPara.lDescribe];
    
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
    if (isOffline) {
        
    } else {
        readThread = [[NSThread alloc] initWithTarget:self selector:@selector(readDataSetParaThread) object:nil];
        [readThread start];
        _uiTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshUi) userInfo:nil repeats:YES];
        [_uiTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (isOffline) {
        
    } else {
        [_uiTimer setFireDate:[NSDate distantFuture]];
        [readThread cancel];
        [_uiTimer invalidate];
        _uiTimer = nil;
    }

}

- (instancetype)initWithDescDealer:(WJCDescDealer *)rDescDealer withPara:(WJCOneParameter *)rPara withComm:(WJCHiCommunicator *)rHiCom withIsOffline:(Boolean)rIsOffline withParaName:(NSString *)rName{
    if (self = [super init]) {
        _descDealer = rDescDealer;
        _nowPara = rPara;
        hiComm = rHiCom;
        paraName = rName;
        isOffline = rIsOffline;
    }
    return self;
}

- (void)refreshUi{
    [self.tableView reloadData];
}

#pragma mark - 读取线程
- (void)readDataSetParaThread{
    while (1) {
        if (!_nowPara.isArray) {
            NSString *recStr = @"";
            for (int i=0; i<2; i++) {
                if (_nowPara.isString) {
                    recStr = [hiComm readStringData:_nowPara.index subindex:i];
                    
                    
                } else {
                    recStr = [hiComm readData:_nowPara.index subindex:i];
                }
                [_nowPara setValHexWithSubindex:i withArrayIndex:0 val:recStr];
                
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
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"if_local"];
    } else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"if_localp"];
    }
    if (_nowPara.isArray) {
        cell.textLabel.text = @"矩阵参数，请点击查看";//[NSString stringWithFormat:@"子索引%@",_onepa];
    } else {
        cell.textLabel.text = [_nowPara showParaDesc:[_nowPara valHexWithSubindex:indexPath.row withArrayIndex:0] descD:self.descDealer];//[NSString stringWithFormat:@"子索引%@",_onepa];
        
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"子索引%ld",indexPath.row];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    //cell图片尺寸适当
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_nowPara.isArray) {
        WJCArrayParaTable *tempT = [[WJCArrayParaTable alloc] initWithDescDealer:_descDealer withPara:_nowPara withComm:hiComm withIsOffline:isOffline withParaName:paraName withSubindex:indexPath.row];
        [self.navigationController pushViewController:tempT animated:YES];
    } else {
        WJCUiParaEditor *paraView = [[WJCUiParaEditor alloc] initWitPara:self.nowPara withName:paraName withDescDealer:self.descDealer withSubindex:indexPath.row withArrayIndex:0 withCom:hiComm withOffline:isOffline];
        [self.navigationController pushViewController:paraView animated:YES];
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
