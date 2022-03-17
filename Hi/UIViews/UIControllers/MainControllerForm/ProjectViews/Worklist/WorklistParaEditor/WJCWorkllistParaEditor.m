//
//  WJCWorkllistParaEditor.m
//  Hi
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCWorkllistParaEditor.h"
#import "ZKSegment.h"
#import "WJCUiParaEditor.h"
#import "WJCGlobalConstants.h"
#import "WJCCommonFunctions.h"

typedef enum {
    WJCWorklistEditorOnlineData,WJCWorklistEditorSettingData
}WJCWorklistEditorType;

@interface WJCWorkllistParaEditor ()<UITableViewDelegate,UITableViewDataSource>{
    WJCWorklistEditorType editorType;         //当前编辑模式
    int sectionNum;     //分组内容
    int descSectionNum;  //描述的分组数
    int subindex;
    int arrayIndex;
    float t1,t2,t3,t4,t5;
    
    NSString *displayOnlineValue;
    NSString *displaySettingValue;
}


@property (nonatomic,strong)  WJCDevice *nowHiDevice;  //传入的Hi device
@property (nonatomic,strong)  WJCHiWorklistItem *nowWorklistItem;  //

//界面
@property (nonatomic, strong)ZKSegment *zkSegment;
@property (nonatomic,assign)ZKSegmentStyle zkSegmentStyle;
@property (nonatomic,strong)  UITableView *paraTableView;  //
//    @property(nonatomic,strong) UIButton *button ; //模拟cell的button
@property (nonatomic,strong)  UITextField *textField;  //

@property(nonatomic,strong) NSMutableDictionary* dic;//用来判断分组展开与收缩的

@property (nonatomic,strong)  NSMutableArray<NSMutableArray<WJCTableItemInfo *> *> *descArray;  //

@property (nonatomic,strong)  NSMutableArray<NSString *> *descTittleArray1;  //
@property (nonatomic,strong)  NSMutableArray<NSString *> *descTittleArray2;  //
@end

@implementation WJCWorkllistParaEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDescType];
    [self setUI];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.paraTableView.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化
- (instancetype)initWithWorklistItem:(WJCHiWorklistItem*)rWkltItem withHiDevice:(WJCDevice *)rDevice withSubindex:(int)rSubi withArrayIndex:(int)rArrI{
    if (self = [super init]) {
        _nowHiDevice = rDevice;
        _nowWorklistItem = rWkltItem;
        subindex = rSubi;
        arrayIndex = rArrI;
        displayOnlineValue = [_nowWorklistItem.nowPara showParaWithoutDesc:[_nowWorklistItem.nowPara valHexWithSubindex:subindex withArrayIndex:arrayIndex] descD:_nowHiDevice.descDealer];
        displaySettingValue = [_nowWorklistItem offlineStrValWithSubindex:rSubi withArrayIndex:rArrI];
        
        editorType = WJCWorklistEditorOnlineData;
    }
    return self;
}

#pragma mark - 显示参数后台数据更新

- (void)setDescType{
    //DDT_NONE, DDT_NONE_BIT, DDT_DESC_NORMAL, DDT_DESC_BIT, DDT_DESC_BITS
    NSString *tempDispStr = @"";
    switch (editorType) {
        case WJCWorklistEditorOnlineData:
            tempDispStr = displayOnlineValue;
            break;
            
        case WJCWorklistEditorSettingData:
            tempDispStr = displaySettingValue;
            break;
    }
    
    WJCOneParameter *editPara = self.nowWorklistItem.nowPara;
    WJCDescDealer *descDealer = self.nowHiDevice.descDealer;
    switch (editPara.descTypeEnum) {
        case DDT_NONE:{
            sectionNum = 5;
            break;
        }
        case DDT_NONE_BIT:{
            sectionNum = 6;
            descSectionNum = 1;
            _descArray = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            
            NSInteger decbCnt = editPara.len * 8;
            NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
            int dispHexData = strtoul([tempDispStr UTF8String], 0, 16);
            for (int i=0; i<decbCnt; i++) {
                WJCTableItemInfo *tempTableItem = [WJCTableItemInfo tableItemInfoWithString:[NSString stringWithFormat:@"bit%d",i]];
                tempTableItem.val = i;
                if ((dispHexData >> tempTableItem.val) & 1) {
                    tempTableItem.isSeclected = YES;
                } else {
                    tempTableItem.isSeclected = NO;
                }
                [tempOneDescArr addObject:tempTableItem];
            }
            //            tempOneDescArr[0].isSeclected = YES;
            [_descArray addObject:tempOneDescArr];
            break;
        }
        case DDT_DESC_NORMAL:{
            sectionNum = 6;
            descSectionNum = 1;
            //创建描述参数组 section
            _descArray = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray1 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray2 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            
            int tInd = [descDealer getDescIndexFromInd:editPara.index];
            NSInteger decbCnt = descDealer.descTabs.items[tInd].items.count;
            NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
            for (int i=0; i<decbCnt; i++) {
                WJCTableItemInfo *tempTableItem = [WJCTableItemInfo tableItemInfoWithDescItem:descDealer.descTabs.items[tInd].items[i]];
                
                if ([tempDispStr isEqualToString:[NSString stringWithFormat:@"%d",descDealer.descTabs.items[tInd].items[i]->value]]) {
                    tempTableItem.isSeclected = YES;
                    
                    //设置section tittle
                    NSString * tempTittle = @"";
                    [_descTittleArray1 addObject:tempTittle];
                    tempTittle = descDealer.descTabs.items[tInd].items[i].useString;
                    [_descTittleArray2 addObject:tempTittle];
                }
                
                [tempOneDescArr addObject:tempTableItem];
            }
            //            tempOneDescArr[0].isSeclected = YES;
            [_descArray addObject:tempOneDescArr];
            
            break;
        }
        case DDT_DESC_BIT:{
            sectionNum = 6;
            descSectionNum = 1;
            
            _descArray = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray1 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray2 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            
            int tInd = [descDealer getDescIndexFromInd:editPara.index];
            NSInteger decbCnt = descDealer.descTabs.items[tInd].items.count;
            NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
            int dispHexData = strtoul([tempDispStr UTF8String], 0, 16);
            for (int i=0; i<decbCnt; i++) {
                WJCTableItemInfo *tempTableItem = [WJCTableItemInfo tableItemInfoWithDescItem:descDealer.descTabs.items[tInd].items[i]];
                if ((dispHexData >> tempTableItem.val) & 1) {
                    tempTableItem.isSeclected = YES;
                } else {
                    tempTableItem.isSeclected = NO;
                }
                [tempOneDescArr addObject:tempTableItem];
            }
            //            tempOneDescArr[0].isSeclected = YES;
            [_descArray addObject:tempOneDescArr];
            break;
        }
        case DDT_DESC_BITS:{
            
            int tInd = [descDealer getDescIndexFromInd:editPara.index];
            descSectionNum = descDealer.combineIndexes.items[tInd].items.count;
            sectionNum = 5 + descSectionNum;
            
            _descArray = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray1 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray2 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            
            
            for (int i=0; i<descSectionNum; i++) {
                NSInteger decbCnt = descDealer.descTabs.items[descDealer.combineIndexes.items[tInd].items[i]->index].items.count;
                NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
                for (int j=0; j<decbCnt; j++) {
                    WJCTableItemInfo *tempTableItem ;
                    if (j==0) {
                        tempTableItem = [WJCTableItemInfo tableItemInfoWithString:descDealer.descTabs.items[descDealer.combineIndexes.items[tInd].items[i]->index].items[j]->desc];
                        [_descTittleArray1 addObject:descDealer.descTabs.items[descDealer.combineIndexes.items[tInd].items[i]->index].items[j]->desc];
                    } else {
                        tempTableItem = [WJCTableItemInfo tableItemInfoWithDescItem:descDealer.descTabs.items[descDealer.combineIndexes.items[tInd].items[i]->index].items[j]];
                    }
                    
                    [tempOneDescArr addObject:tempTableItem];
                }
                [_descArray addObject:tempOneDescArr];
            }
            
            NSInteger dispHexData = strtoul([tempDispStr UTF8String], 0, 16);
            int rLen = 0;
            for (int i=0; i<descSectionNum; i++) {
                int rlen2 = descDealer.combineIndexes.items[tInd].items[i]->len;
                int valD = (dispHexData >> rLen) & (((int)(pow(2, rlen2))-1));
                _descArray[i][valD+1].isSeclected = YES;
                [_descTittleArray2 addObject:_descArray[i][valD+1].infoDesc];
                rLen = rLen + rlen2;
            }
            
            break;
        }
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

- (WJCCheckRange)checkWriteData:(NSString *)rData{
    WJCCheckRange resultRange = CR_OK;
    WJCOneParameter *editPara = _nowWorklistItem.nowPara;
    if (editPara.isHex) {
        NSInteger hexVal = strtoul([rData UTF8String], 0, 16);
        NSInteger hexMax = strtoul([editPara.maxHex UTF8String], 0, 16);
        NSInteger hexMin = strtoul([editPara.minHex UTF8String], 0, 16);
        
        if (hexVal > hexMax) {
            resultRange = CR_TOOBIG;
        } else if (hexVal < hexMin){
            resultRange = CR_TOOSMALL;
        }
    } else if (editPara.isDate) {  //wjc20180328
        
    } else {
        double dD = [rData doubleValue];
        
        if (dD > editPara.maxVal) {
            resultRange = CR_TOOBIG;
        } else if (dD < editPara.minVal){
            resultRange = CR_TOOSMALL;
        }
    }
    
    return resultRange;
}

- (void)write{
    WJCOneParameter *editPara = _nowWorklistItem.nowPara;
    if (_nowHiDevice.isOffline && (editorType == WJCWorklistEditorOnlineData)) {
        [self popDialogWithTittle:@"提示" message:@"离线模式，无法写入"];
    } else {
        if (editPara.isReadonly) {
            [self popDialogWithTittle:@"提示" message:@"只读参数，无法写入"];
        } else {
            WJCCheckRange tempCheckRange;
            NSString *toWriteData = self.textField.text;
            if (editPara.isString) {
                tempCheckRange = CR_OK;
            } else {
                tempCheckRange = [self checkWriteData:toWriteData];
            }
            
            switch (tempCheckRange) {
                case CR_TOOSMALL:
                    [self popDialogWithTittle:@"提示" message:@"输入值超下限"];
                    break;
                case CR_TOOBIG:
                    [self popDialogWithTittle:@"提示" message:@"输入值超上限"];
                    break;
                case CR_OK:{
                    NSString *writeResult;
                    
                    switch (editorType) {
                        case WJCWorklistEditorOnlineData:
                            
                            if (editPara.isString) {
                                writeResult = [_nowHiDevice.hiCom writeStringWithIndex:editPara.index withSubindex:subindex withStringData:dispToHex(toWriteData, editPara)];//:_editPara.index withSubindex:subindex withData:dispToHex(toWriteData, _editPara) withDataLen:_editPara.len];
                            } else if(editPara.isArray){
                                writeResult = [_nowHiDevice.hiCom writeArrayWithIndex:editPara.index withSubindex:subindex withArrayIndex:arrayIndex withData:dispToHex(toWriteData, editPara) withDataLen:editPara.len];
                            } else {
                                writeResult = [_nowHiDevice.hiCom writeWithIndex:editPara.index withSubindex:subindex withData:dispToHex(toWriteData, editPara) withDataLen:editPara.len];
                                
                            }
                            
                            if ([writeResult isEqualToString:COMM_SUC]) {
                                [self popDialogWithTittle:@"提示" message:@"在线值写入成功"];
                            } else {
                                [self popDialogWithTittle:@"提示" message:@"在线值写入失败"];
                            }
                            
                            break;
                            
                        case WJCWorklistEditorSettingData:
                            displaySettingValue = toWriteData;
                            [_nowWorklistItem setOfflineStrValWithSubindex:subindex withArrayIndex:arrayIndex withStrVal:displaySettingValue];
                            [self popDialogWithTittle:@"提示" message:@"设定值写入成功"];
                            
                            break;
                    }

                    
                    break;
                }
                case CR_ERR:
                    [self popDialogWithTittle:@"提示" message:@"输入值有误"];
                    break;
                    
            }
            [NSThread detachNewThreadSelector:@selector(reReadData) toTarget:self withObject:nil];
            //        [self reReadData];
            //        [self popDialogWithTittle:@"提示" message:@"测试写入按钮"];
            
            
        }
    }
    
    
}

- (void)reReadData{
    switch (editorType) {
        case WJCWorklistEditorSettingData:
            
            break;
            
        case WJCWorklistEditorOnlineData:{
            WJCOneParameter *editPara = _nowWorklistItem.nowPara;
            int retryTimes = 0;
            NSString *recString = COMM_TIMEOUT;
            while ((retryTimes <3) && (isErr(recString))) {
                if (editPara.isString) {
                    recString = [_nowHiDevice.hiCom readStringData:editPara.index subindex:subindex];
                } else if (editPara.isArray) {
                    recString = [_nowHiDevice.hiCom readArrayDataWithIndex:editPara.index withSubindex:subindex withArrayIndex:arrayIndex];
                } else{
                    recString = [_nowHiDevice.hiCom readData:editPara.index subindex:subindex];
                }
                [NSThread sleepForTimeInterval:0.02f];
                retryTimes++;
            }
            [editPara setValHexWithSubindex:subindex withArrayIndex:arrayIndex val:recString];
            displayOnlineValue = [editPara showParaWithoutDesc:[editPara valHexWithSubindex:subindex withArrayIndex:arrayIndex] descD:_nowHiDevice.descDealer];
        
            break;
        }
    }

    [self setDescType];
    [self.paraTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    //    [self.paraTableView reloadData];
}

#pragma mark - 创建界面
- (void)setUI{
    //
    self.title = [NSString stringWithFormat:@"%@ %@",_nowWorklistItem.sName,_nowWorklistItem.nowPara.lDescribe];//_nowWorklistItem.sName;
    
    
    //左右切换栏目创建
    self.zkSegmentStyle = ZKSegmentRectangleStyle;
    [self resetSegment];
    
    t4 = self.zkSegment.frame.size.height;
    //创建Table
    UITableView *paraTable = [[UITableView alloc] initWithFrame:CGRectMake(0, t4+t1+t2-t3, self.view.frame.size.width, self.view.bounds.size.height-(t4+t1+t2-t3)) style:UITableViewStylePlain];
    _paraTableView = paraTable;
    _paraTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _paraTableView.dataSource = self;
    _paraTableView.delegate = self;
    //使taleView 没有下拉线
    _paraTableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_paraTableView];
    
    //触发键盘的隐藏
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveKeyBoard)];
    tap1.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap1];
}

- (void)leaveKeyBoard{
    [self.textField resignFirstResponder];
}

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
        if (itemIndex == 0) {
            editorType = WJCWorklistEditorOnlineData;
        } else if (itemIndex == 1){
            editorType = WJCWorklistEditorSettingData;
        }
        
        [self setDescType];
        [self.paraTableView reloadData];
        
        
        
    };
    [self.zkSegment zk_setItems:@[ @"在线值", @"设定值" ]];
    [self.view addSubview:self.zkSegment];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (sectionNum);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section<5) {
        return 0;
    } else {
        NSInteger resultInt = 0;
        switch (self.nowWorklistItem.nowPara.descTypeEnum) {
                //            case DDT_NONE:{
                //                resultInt = 0;
                //                break;
                //            }
            case DDT_NONE_BIT:{
                if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                    resultInt = _descArray[0].count;
                } else {
                    resultInt = 0;
                }
                break;
            }
            case DDT_DESC_NORMAL:{
                if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                    resultInt = _descArray[0].count;
                } else {
                    resultInt = 0;
                }
                
                
                
                break;
            }
            case DDT_DESC_BIT:{
                if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                    resultInt = _descArray[0].count;
                } else {
                    resultInt = 0;
                }
                break;
            }
            case DDT_DESC_BITS:{
                if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                    resultInt = _descArray[section-5].count - 1;
                } else {
                    resultInt = 0;
                }
                break;
            }
        }
        return resultInt;
        //        if (section %2 == 0) {
        //            return [_rowArray count];
        //
        //        }else{
        //            return [_rowArray2 count];
        //        }
    }
    
}


//header显示
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSString *tempDispStr = @"";
    switch (editorType) {
        case WJCWorklistEditorOnlineData:
            tempDispStr = displayOnlineValue;
            break;
            
        case WJCWorklistEditorSettingData:
            tempDispStr = displaySettingValue;
            break;
    }
    
    WJCOneParameter *editPara = self.nowWorklistItem.nowPara;
    
    switch (section) {
        case 0:{
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:0.7];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 300 , 30)];
            label.text = [NSString stringWithFormat:@"min = %@ %@    max = %@ %@",editPara.minStr,editPara.symbol,editPara.maxStr,editPara.symbol];
            
            [view addSubview:label];
            return view;
            break;
        }
        case 1:{
            UIView *view = [[UIView alloc] init];
            //        view.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:0.7];
            UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(5, 6, self.view.bounds.size.width-10, 33)];
            
            //判断参数类型，显示不同的键盘
            if (editPara.isString) {
                text.keyboardType = UIKeyboardTypeASCIICapable;
            } else
                text.keyboardType = UIKeyboardTypeDecimalPad;
            
            text.borderStyle = UITextBorderStyleRoundedRect;
            text.font = [UIFont fontWithName:@"Arial" size:22.0f];
            text.returnKeyType = UIReturnKeyDone;
            
            //显示内容
            text.textAlignment = NSTextAlignmentCenter;
            text.text = tempDispStr;
            
            [view addSubview:text];
            self.textField = text;
            [self.textField addTarget:self action:@selector(leaveKeyBoard) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            return view;
            break;
        }
        case 2:{
            
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [button setTitle:[NSString stringWithFormat:@"确定写入"] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor lightGrayColor];
            [button addTarget:self action:@selector(write) forControlEvents:UIControlEventTouchUpInside];
            
            return  button;
            
            
            break;
        }
        case 3:case 4:{
            UIView *view = [[UIView alloc] init];
            
            return view;
            break;
        }
            
        default:{
            NSString *tittle = @"";
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-42, 4, 36, 36)];
            
            switch (editPara.descTypeEnum) {
                case DDT_NONE:{
                    
                    break;
                }
                case DDT_NONE_BIT:{
                    
                    if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                        
                        imageView.image = [UIImage imageNamed:@"if_fold1"];
                    } else {
                        
                        imageView.image = [UIImage imageNamed:@"if_unfold1"];
                    }
                    tittle = tempDispStr;
                    break;
                }
                case DDT_DESC_NORMAL:{
                    
                    if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                        
                        imageView.image = [UIImage imageNamed:@"if_fold1"];
                    } else {
                        
                        //                        tittle = [NSString stringWithFormat:@"%@",_descTittleArray2[section-5]];
                        imageView.image = [UIImage imageNamed:@"if_unfold1"];
                    }
                    if (_descTittleArray2.count>0) {
                        tittle = [NSString stringWithFormat:@"%@",_descTittleArray2[section-5]];//@"点击收起";
                    }
                    break;
                }
                case DDT_DESC_BIT:{
                    if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                        //                        tittle = @"点击收起";
                        imageView.image = [UIImage imageNamed:@"if_fold1"];
                    } else {
                        //                        tittle = @"点击展开";
                        imageView.image = [UIImage imageNamed:@"if_unfold1"];
                    }
                    tittle = tempDispStr;
                    break;
                }
                case DDT_DESC_BITS:{
                    if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {
                        
                        imageView.image = [UIImage imageNamed:@"if_fold1"];
                    } else {
                        
                        imageView.image = [UIImage imageNamed:@"if_unfold1"];
                    }
                    NSArray *tittleArr = [_descTittleArray2[section-5] componentsSeparatedByString:@":"];
                    NSString *tittlePart2 = @"";
                    if (tittleArr.count == 2) {
                        tittlePart2 = tittleArr[1];
                    }
                    tittle = [NSString stringWithFormat:@"%@: %@",_descTittleArray1[section-5],tittlePart2];
                    break;
                }
            }
            
            //将button作为表头
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = section;
            [button setTitle:[NSString stringWithFormat:@"%@",tittle] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor grayColor];//[UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:0.7];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
            
            [button addSubview:imageView];
            return button;
            break;
        }
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]]) {
    return 44;
    //    }
    //    return 0;
}

//每个cell显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    switch (self.nowWorklistItem.nowPara.descTypeEnum) {
        case DDT_NONE:{
            
            break;
        }
        case DDT_NONE_BIT:{
            cell.textLabel.text = _descArray[0][indexPath.row].infoDesc;
            if (_descArray[0][indexPath.row].isSeclected) {
//                cell.imageView.image = [UIImage imageNamed:@"if_check"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_on"];
                
            } else {
//                cell.imageView.image = [UIImage imageNamed:@"if_caution"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_off"];
            }
            break;
        }
        case DDT_DESC_NORMAL:{
            
            cell.textLabel.text = _descArray[0][indexPath.row].infoDesc;
            if (_descArray[0][indexPath.row].isSeclected) {
//                cell.imageView.image = [UIImage imageNamed:@"if_check"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_on"];
                
            } else {
//                cell.imageView.image = [UIImage imageNamed:@"if_caution"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_off"];
            }
            break;
        }
        case DDT_DESC_BIT:{
            cell.textLabel.text = _descArray[0][indexPath.row].infoDesc;
            if (_descArray[0][indexPath.row].isSeclected) {
//                cell.imageView.image = [UIImage imageNamed:@"if_check"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_on"];
                
            } else {
//                cell.imageView.image = [UIImage imageNamed:@"if_caution"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_off"];
            }
            break;
        }
        case DDT_DESC_BITS:{
            cell.textLabel.text = _descArray[indexPath.section-5][indexPath.row+1].infoDesc;
            if (_descArray[indexPath.section-5][indexPath.row+1].isSeclected) {
//                cell.imageView.image = [UIImage imageNamed:@"if_check"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_on"];
                
            } else {
//                cell.imageView.image = [UIImage imageNamed:@"if_caution"];
                cell.imageView.image = [UIImage imageNamed:@"radio_btn_off"];
            }
            break;
        }
    }
    //    if (indexPath.section %2 == 0) {
    //        cell.textLabel.text = [NSString stringWithFormat:@"第%ld个cell : %@",indexPath.row+1,_rowArray[indexPath.row]];
    //    }else{
    //        cell.textLabel.text = [NSString stringWithFormat:@"第%ld个cell : %@",indexPath.row+1,_rowArray2[indexPath.row]];
    //    }
    
    //cell图片尺寸适当
    CGSize itemSize = CGSizeMake(25, 25);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    //cell分隔线
    [cell setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


    NSString *tempDispStr = @"";
    if (indexPath.section>4) {
        switch (self.nowWorklistItem.nowPara.descTypeEnum) {
            case DDT_NONE:{
                
                break;
            }
            case DDT_NONE_BIT:{
                if (_descArray[0][indexPath.row].isSeclected) {
                    _descArray[0][indexPath.row].isSeclected = NO;
                } else
                    _descArray[0][indexPath.row].isSeclected = YES;
                int tempDis = 0;
                for (int i=0; i<_descArray[0].count; i++) {
                    if (_descArray[0][i].isSeclected) {
                        int tempD = 1;
                        tempDis = tempDis + (tempD << _descArray[0][i].val);
                    }
                    
                }
                
                switch (_nowWorklistItem.nowPara.len) {
                    case 1:
                        tempDispStr = [NSString stringWithFormat:@"%02X",tempDis];
                        break;
                    case 2:
                        tempDispStr = [NSString stringWithFormat:@"%04X",tempDis];
                        break;
                    case 4:
                        tempDispStr = [NSString stringWithFormat:@"%08X",tempDis];
                        break;
                    case 8:
                        tempDispStr = [NSString stringWithFormat:@"%16X",tempDis];
                        break;
                }
                switch (editorType) {
                    case WJCWorklistEditorOnlineData:
                        displayOnlineValue = tempDispStr;
                        break;
                        
                    case WJCWorklistEditorSettingData:
                        displaySettingValue = tempDispStr;
                        break;
                }
                //                dispValue = [NSString stringWithFormat:@"%04X",tempDis];
                [self.paraTableView reloadData];
                //                [self.paraTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
            case DDT_DESC_NORMAL:{
                for (int i = 0; i<_descArray[0].count; i++) {
                    _descArray[0][i].isSeclected = NO;
                }
                _descArray[0][indexPath.row].isSeclected = YES;
                _descTittleArray2[0] = _descArray[0][indexPath.row].infoDesc;
                tempDispStr = [NSString stringWithFormat:@"%d",_descArray[0][indexPath.row].val];
                switch (editorType) {
                    case WJCWorklistEditorOnlineData:
                        displayOnlineValue = tempDispStr;
                        break;
                        
                    case WJCWorklistEditorSettingData:
                        displaySettingValue = tempDispStr;
                        break;
                }
                [self.paraTableView reloadData];
                //                [self.paraTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                //[self.paraTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            case DDT_DESC_BIT:{
                if (_descArray[0][indexPath.row].isSeclected) {
                    _descArray[0][indexPath.row].isSeclected = NO;
                } else
                    _descArray[0][indexPath.row].isSeclected = YES;
                int tempDis = 0;
                for (int i=0; i<_descArray[0].count; i++) {
                    if (_descArray[0][i].isSeclected) {
                        int tempD = 1;
                        tempDis = tempDis + (tempD << _descArray[0][i].val);
                    }
                    
                }
                switch (_nowWorklistItem.nowPara.len) {
                    case 1:
                        tempDispStr = [NSString stringWithFormat:@"%02X",tempDis];
                        break;
                    case 2:
                        tempDispStr = [NSString stringWithFormat:@"%04X",tempDis];
                        break;
                    case 4:
                        tempDispStr = [NSString stringWithFormat:@"%08X",tempDis];
                        break;
                    case 8:
                        tempDispStr = [NSString stringWithFormat:@"%16X",tempDis];
                        break;
                }
                switch (editorType) {
                    case WJCWorklistEditorOnlineData:
                        displayOnlineValue = tempDispStr;
                        break;
                        
                    case WJCWorklistEditorSettingData:
                        displaySettingValue = tempDispStr;
                        break;
                }
                //                dispValue = [NSString stringWithFormat:@"%04X",tempDis];
                [self.paraTableView reloadData];
                //                [self.paraTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
            case DDT_DESC_BITS:{
                for (int i = 1; i<_descArray[indexPath.section-5].count; i++)
                {
                    _descArray[indexPath.section-5][i].isSeclected = NO;
                }
                _descArray[indexPath.section-5][indexPath.row+1].isSeclected = YES;
                _descTittleArray2[indexPath.section-5] = _descArray[indexPath.section-5][indexPath.row+1].infoDesc;
                
                int tInd = [_nowHiDevice.descDealer getDescIndexFromInd:self.nowWorklistItem.nowPara.index];
                
                NSInteger val = 0;
                NSInteger sPos = 0;
                for (int i=0; i<_descArray.count; i++)
                {
                    int tempVl = 0;
                    for (int j=0; j<_descArray[i].count; j++) {
                        if (_descArray[i][j].isSeclected) {
                            tempVl = _descArray[i][j].val;
                            break;
                        }
                    }
                    val = val + (tempVl << sPos);
                    sPos = sPos + _nowHiDevice.descDealer.combineIndexes.items[tInd].items[i]->len;
                }
                switch (_nowWorklistItem.nowPara.len) {
                    case 1:
                        tempDispStr = [NSString stringWithFormat:@"%02X",val];
                        break;
                    case 2:
                        tempDispStr = [NSString stringWithFormat:@"%04X",val];
                        break;
                    case 4:
                        tempDispStr = [NSString stringWithFormat:@"%08X",val];
                        break;
                    case 8:
                        tempDispStr = [NSString stringWithFormat:@"%16X",val];
                        break;
                }
                switch (editorType) {
                    case WJCWorklistEditorOnlineData:
                        displayOnlineValue = tempDispStr;
                        break;
                        
                    case WJCWorklistEditorSettingData:
                        displaySettingValue = tempDispStr;
                        break;
                }
                [self.paraTableView reloadData];
                //                [self.paraTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

//展开收缩cell
-(void)buttonAction:(UIButton*)sender{
    NSInteger didSection = sender.tag;
    if (!_dic) {
        _dic = [[NSMutableDictionary alloc]init];
    }
    NSString *key  = [NSString stringWithFormat:@"%ld",didSection];
    if (![_dic objectForKey:key]) {
        [_dic setObject:@"" forKey:key];
    }else{
        [_dic removeObjectForKey:key];
    }
    [self.paraTableView reloadData];
    
    //    [self.paraTableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationFade];//UITableViewRowAnimationFade];
}

@end
