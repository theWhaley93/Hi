//
//  WJCUiMainForm.m
//  Hi
//
//  Created by apple on 2018/3/8.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCUiMainForm.h"
#import "WJCDevice.h"
#import "WJCOneParaViewCell.h"
#import "WJCGlobalConstants.h"

@interface WJCUiMainForm ()<UITableViewDataSource,UITabBarDelegate,UITableViewDelegate,UIScrollViewDelegate>{
    Boolean t;
    int nowGroup;
    Boolean changeGroupB;
    int tempG ;
    Boolean scrollChange;
}
@property (weak, nonatomic) IBOutlet UITableView *paraTable;

@property (nonatomic,strong)  NSThread *nowThread;  //


@property (nonatomic,strong)  NSArray<NSIndexPath *> *visibleCells;  //

@end

@implementation WJCUiMainForm

- (IBAction)g01B:(id)sender {
    tempG = 1;
    changeGroupB = YES;
}
- (IBAction)g2B:(id)sender {
    tempG = 2;
    changeGroupB = YES;
}
- (IBAction)g3B:(id)sender {
    tempG = 3;
    changeGroupB = YES;
}
- (IBAction)g4B:(id)sender {
    tempG = 25;
    changeGroupB = YES;
}
- (IBAction)groupChangeBtn:(id)sender {
    tempG = 0;
    changeGroupB = YES;
    
}
-(void)setTable{
    if (self->t) {
//        self.paraTable.dataSource = self;
//        self.paraTable.rowHeight = 52.5f;
        self->t = NO;
    } else {
        [self.paraTable reloadData];
        
//        [self.paraTable reloadInputViews];
        //        NSArray *visibleCells = [self.parasTable indexPathsForVisibleRows];
        //        [self.parasTable reloadData];
        //        NSLog(@"%d",visibleCells.count);
//        for (int i=0; i<self.visibleCells.count; i++)
        {
//            [self.paraTable reloadRowsAtIndexPaths:self.visibleCells withRowAnimation:UITableViewRowAnimationAutomatic];
            //            [self.parasTable reloadRowsAtIndexPaths:<#(nonnull NSArray<NSIndexPath *> *)#> withRowAnimation:<#(UITableViewRowAnimation)#>]
        }
        //        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        //        [self.parasTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
    
}


- (void)changeGroup{
    
    [_paraTable reloadData];
}
- (void)leftClick{
    [_nowThread cancel];
    [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
}


- (void)readVisibleCells{
    self.visibleCells = [self.paraTable indexPathsForVisibleRows];
}

- (void)readThread{
    
    while (1) {
        WJCOneGroup *tpGroup = hiDevice.paras.actualGroup[self->nowGroup];
        //            NSArray *visibleCells = [self.parasTable indexPathsForVisibleRows];
        //            NSInteger count = visibleCells.count;
        
//        [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
        if (self.visibleCells.count <= 0) {
            [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
        }
        for (int i = self.visibleCells[0].row; i<=self.visibleCells[self.visibleCells.count-1].row; i++)
//        for (int i = 0; i<tpGroup.visibleItems.count; i++)
        {

            
            NSString *tempps = [hiDevice.hiCom readData:tpGroup.visibleItems[i]->index subindex:0];//[self.hiCom readData:((WJCOneParameter *)(self.paraArray[i])).index subindex:0];
            [hiDevice.paras.paras[tpGroup.visibleItems[i]->index] setValHexWithSubindex:0 withArrayIndex:0 val:tempps];
            if (([tempps length] != ([hiDevice.paras.paras[tpGroup.visibleItems[i]->index].defHex length])) && (![tempps isEqualToString:COMM_TIMEOUT]) ){
                NSLog(@"%@--%@--%@",hiDevice.paras.paras[tpGroup.visibleItems[i]->index].sDescribe,hiDevice.paras.paras[tpGroup.visibleItems[i]->index].defHex,tempps);
            }
            
            [NSThread sleepForTimeInterval:0.01f];
            

            
            
            if (changeGroupB) {
                changeGroupB = NO;
                self->nowGroup = tempG;
                //            [self performSelectorOnMainThread:@selector(changeGroup) withObject:nil waitUntilDone:YES];
                [_paraTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
                tpGroup = hiDevice.paras.actualGroup[self->nowGroup];
                continue;
            }
            
            if (scrollChange) {
                scrollChange = NO;
                [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
                continue;
            }
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
                
            }
        }

        


        [self performSelectorOnMainThread:@selector(setTable) withObject:nil waitUntilDone:NO];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //删除tableview中多余的cell
    self.paraTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.paraTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.paraTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self->t = YES;
    self.paraTable.dataSource = self;
    self.paraTable.rowHeight = 52.5f;
    self.paraTable.delegate = self;
    self->nowGroup = 0;
    changeGroupB = NO;
    scrollChange = NO;
    
    [self performSelectorOnMainThread:@selector(readVisibleCells) withObject:nil waitUntilDone:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftClick)];
    
    
    _nowThread = [[NSThread alloc] initWithTarget:self selector:@selector(readThread) object:nil];
    [_nowThread start];

    /*
    WJCOneGroup *tpGroup = hiDevice.paras.actualGroup[0];
    [NSThread detachNewThreadWithBlock:^{
        while (1) {
            //            NSArray *visibleCells = [self.parasTable indexPathsForVisibleRows];
            //            NSInteger count = visibleCells.count;
            for (int i = 0; i<tpGroup.visibleItems.count; i++) {
                //互斥锁
                //                @synchronized(globelMutexTest){
                //                    NSString *tempps = [self.hiCom readData:((WJCOneParameter *)(self.paraArray[i])).index subindex:0];
                //                    [((WJCOneParameter *)(self.paraArray[i])) setValHex:0 arrayIndex:0 val:tempps];
                //                }
                NSString *tempps = [hiDevice.hiCom readData:tpGroup.visibleItems[i]->index subindex:0];//[self.hiCom readData:((WJCOneParameter *)(self.paraArray[i])).index subindex:0];
                [hiDevice.paras.paras[tpGroup.visibleItems[i]->index] setValHex:0 arrayIndex:0 val:tempps];
                if (([tempps length] != ([hiDevice.paras.paras[tpGroup.visibleItems[i]->index].defHex length])) && (![tempps isEqualToString:COMM_TIMEOUT]) ){
                    NSLog(@"%@--%@--%@",hiDevice.paras.paras[tpGroup.visibleItems[i]->index].sDescribe,hiDevice.paras.paras[tpGroup.visibleItems[i]->index].defHex,tempps);
                }
                [NSThread sleepForTimeInterval:0.02f];
            }
            [self performSelectorOnMainThread:@selector(setTable) withObject:nil waitUntilDone:NO];
            _nowThread = [NSThread currentThread];
        }
        
    }];
     */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table显示
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return hiDevice.paras.actualGroup[self->nowGroup].visibleItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
     static NSString *identifier= @"car";
     WJCCarView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
     if (cell == nil) {
     cell = [[[NSBundle mainBundle] loadNibNamed:@"CarView" owner:nil options:nil] firstObject];
     }
     */
    
    WJCOneParaViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [WJCOneParaViewCell oneParaViewCellWithTableView:tableView];
    }
//    cell.descDealer = hiDevice.descDealer;
//    cell.onePara = hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index];
    [cell loadCellInfoWithPara:hiDevice.paras.paras[hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->index] withParaName:hiDevice.paras.actualGroup[self->nowGroup].visibleItems[indexPath.row]->abbreviativeName withDesc:hiDevice.descDealer];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

//    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollChange = YES;
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
