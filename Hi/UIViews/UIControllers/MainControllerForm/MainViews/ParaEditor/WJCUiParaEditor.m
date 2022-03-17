//
//  WJCUiParaEditor.m
//  Hi
//
//  Created by apple on 2018/3/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCUiParaEditor.h"
#import <math.h>
#import "WJCGlobalConstants.h"
#import "WJCCommonFunctions.h"


@implementation WJCTableItemInfo


- (instancetype)initWithString:(NSString *)rDesc{
    if (self = [super init]) {
        _infoDesc = rDesc;
        _isSeclected = NO;
    }
    return self;
}

+ (instancetype)tableItemInfoWithString:(NSString *)rDesc{
    return [[WJCTableItemInfo alloc] initWithString:rDesc];
}

- (instancetype)initWithDescItem:(WJCDescTabItem *)rDescItem{
    if (self = [super init]) {
        _infoDesc = rDescItem.useString;
        _val = rDescItem->value;
        _isSeclected = NO;
    }
    return self;
}

+ (instancetype)tableItemInfoWithDescItem:(WJCDescTabItem *)rDescItem{
    return [[WJCTableItemInfo alloc] initWithDescItem:rDescItem];
}

@end


@interface WJCUiParaEditor ()<UITableViewDataSource,UITableViewDelegate>{
    int sectionNum;     //分组内容
    int descSectionNum;  //描述的分组数
    int subindex;
    int arrayIndex;
    
    NSString *dispValue;
}

@property (nonatomic,strong)  UITableView *paraTableView;  //
//    @property(nonatomic,strong) UIButton *button ; //模拟cell的button
@property (nonatomic,strong)  UITextField *textField;  //
//@property(nonatomic,strong) NSArray *sectionArray;//section标题
//@property(nonatomic,strong) NSArray *rowArray;//模拟数据源
//@property(nonatomic,strong) NSArray *rowArray2;//模拟数据源
@property(nonatomic,strong) NSMutableDictionary* dic;//用来判断分组展开与收缩的

@property (nonatomic,strong)  NSMutableArray<NSMutableArray<WJCTableItemInfo *> *> *descArray;  //

@property (nonatomic,strong)  NSMutableArray<NSString *> *descTittleArray1;  //
@property (nonatomic,strong)  NSMutableArray<NSString *> *descTittleArray2;  //

@end

@implementation WJCUiParaEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",_name,_editPara.lDescribe];
    
    [self setDescType];
    [self setView];
    //使taleView 没有下拉线
    _paraTableView.showsVerticalScrollIndicator = NO;
//    _sectionArray = @[@"描述1",@"描述2",@"描述3",@"描述4",@"描述5"];
//    _rowArray = @[@"test1",@"test2",@"test3",@"test4",@"test5"];
//    _rowArray2 = @[@"test1",@"test2",@"test3"];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9){
        self.paraTableView.cellLayoutMarginsFollowReadableWidth = NO;//9.0以上才有这个属性，针对ipad
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWitPara:(WJCOneParameter *) para withName:(NSString *)name withDescDealer:(WJCDescDealer *)rDescDealer withSubindex:(int)rSubindex withArrayIndex:(int)rArrayIndex withCom:(WJCHiCommunicator *)rComm withOffline:(Boolean)rIsOffline{
    if (self = [super init]) {
        _editPara = para;
        _name = name;
        _descDealer = rDescDealer;
        hiComm = rComm;
        subindex = rSubindex;
        arrayIndex = rArrayIndex;
        dispValue = [_editPara showParaWithoutDesc:[_editPara valHexWithSubindex:subindex withArrayIndex:arrayIndex] descD:_descDealer];
        _isOffline = rIsOffline;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.textField != nil) {
        [self.textField resignFirstResponder];
    }
}
#pragma mark - UI界面创建

- (void)setView{
    UITableView *paraTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _paraTableView = paraTable;
    _paraTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _paraTableView.dataSource = self;
    _paraTableView.delegate = self;
    
    [self.view addSubview:_paraTableView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveKeyBoard)];
    tap1.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap1];
    
}

#pragma mark - UI界面具体动作

- (void)leaveKeyBoard{
    [self.textField resignFirstResponder];
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

- (void)reReadData{
    int retryTimes = 0;
    NSString *recString = COMM_TIMEOUT;
    while ((retryTimes <3) && (isErr(recString))) {
        if (_editPara.isString) {
            recString = [hiComm readStringData:_editPara.index subindex:subindex];
        } else if (_editPara.isArray) {
            recString = [hiComm readArrayDataWithIndex:_editPara.index withSubindex:subindex withArrayIndex:arrayIndex];
        } else{
            recString = [hiComm readData:_editPara.index subindex:subindex];
        }
        [NSThread sleepForTimeInterval:0.02f];
        retryTimes++;
    }
    [_editPara setValHexWithSubindex:subindex withArrayIndex:arrayIndex val:recString];
    dispValue = [_editPara showParaWithoutDesc:[_editPara valHexWithSubindex:subindex withArrayIndex:arrayIndex] descD:_descDealer];
    [self setDescType];
    [self.paraTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
//    [self.paraTableView reloadData];
}

- (void)write{
    if (_isOffline) {
        [self popDialogWithTittle:@"提示" message:@"离线模式，无法写入"];
    } else {
        if (_editPara.isReadonly) {
            [self popDialogWithTittle:@"提示" message:@"只读参数，无法写入"];
        } else {
            WJCCheckRange tempCheckRange;
            NSString *toWriteData = self.textField.text;
            if (_editPara.isString) {
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
                    
                    if (_editPara.isString) {
                        writeResult = [hiComm writeStringWithIndex:_editPara.index withSubindex:subindex withStringData:dispToHex(toWriteData, _editPara)];//:_editPara.index withSubindex:subindex withData:dispToHex(toWriteData, _editPara) withDataLen:_editPara.len];
                    } else if(_editPara.isArray){
                        writeResult = [hiComm writeArrayWithIndex:_editPara.index withSubindex:subindex withArrayIndex:arrayIndex withData:dispToHex(toWriteData, _editPara) withDataLen:_editPara.len];
                    } else {
                        writeResult = [hiComm writeWithIndex:_editPara.index withSubindex:subindex withData:dispToHex(toWriteData, _editPara) withDataLen:_editPara.len];

 
                    }
                    
                    if ([writeResult isEqualToString:COMM_SUC]) {
                        [self popDialogWithTittle:@"提示" message:@"写入成功"];
                    } else {
                        [self popDialogWithTittle:@"提示" message:@"写入失败"];
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

- (WJCCheckRange)checkWriteData:(NSString *)rData{
    WJCCheckRange resultRange = CR_OK;
    
    if (_editPara.isHex) {
        NSInteger hexVal = strtoul([rData UTF8String], 0, 16);
        NSInteger hexMax = strtoul([_editPara.maxHex UTF8String], 0, 16);
        NSInteger hexMin = strtoul([_editPara.minHex UTF8String], 0, 16);
        
        if (hexVal > hexMax) {
            resultRange = CR_TOOBIG;
        } else if (hexVal < hexMin){
            resultRange = CR_TOOSMALL;
        }
    } else if (_editPara.isDate) {  //wjc20180328
        
    } else {
        double dD = [rData doubleValue];
        
        if (dD > _editPara.maxVal) {
            resultRange = CR_TOOBIG;
        } else if (dD < _editPara.minVal){
            resultRange = CR_TOOSMALL;
        }
    }
    
    return resultRange;
}

#pragma mark - 显示参数后台数据更新

- (void)setDescType{
    //DDT_NONE, DDT_NONE_BIT, DDT_DESC_NORMAL, DDT_DESC_BIT, DDT_DESC_BITS
    switch (self.editPara.descTypeEnum) {
        case DDT_NONE:{
            sectionNum = 5;
            break;
        }
        case DDT_NONE_BIT:{
            sectionNum = 6;
            descSectionNum = 1;
            _descArray = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            
            NSInteger decbCnt = _editPara.len * 8;
            NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
            int dispHexData = strtoul([dispValue UTF8String], 0, 16);
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
            
            int tInd = [_descDealer getDescIndexFromInd:self.editPara.index];
            NSInteger decbCnt = _descDealer.descTabs.items[tInd].items.count;
            NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
            for (int i=0; i<decbCnt; i++) {
                WJCTableItemInfo *tempTableItem = [WJCTableItemInfo tableItemInfoWithDescItem:_descDealer.descTabs.items[tInd].items[i]];
                
                if ([dispValue isEqualToString:[NSString stringWithFormat:@"%d",_descDealer.descTabs.items[tInd].items[i]->value]]) {
                    tempTableItem.isSeclected = YES;
                    
                    //设置section tittle
                    NSString * tempTittle = @"";
                    [_descTittleArray1 addObject:tempTittle];
                    tempTittle = _descDealer.descTabs.items[tInd].items[i].useString;
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
            
            int tInd = [_descDealer getDescIndexFromInd:self.editPara.index];
            NSInteger decbCnt = _descDealer.descTabs.items[tInd].items.count;
            NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
            int dispHexData = strtoul([dispValue UTF8String], 0, 16);
            for (int i=0; i<decbCnt; i++) {
                WJCTableItemInfo *tempTableItem = [WJCTableItemInfo tableItemInfoWithDescItem:_descDealer.descTabs.items[tInd].items[i]];
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
            
            int tInd = [_descDealer getDescIndexFromInd:self.editPara.index];
            descSectionNum = _descDealer.combineIndexes.items[tInd].items.count;
            sectionNum = 5 + descSectionNum;
            
            _descArray = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray1 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            _descTittleArray2 = [[NSMutableArray alloc] initWithCapacity:descSectionNum];
            
            
            for (int i=0; i<descSectionNum; i++) {
                NSInteger decbCnt = _descDealer.descTabs.items[_descDealer.combineIndexes.items[tInd].items[i]->index].items.count;
                NSMutableArray<WJCTableItemInfo *> *tempOneDescArr = [[NSMutableArray alloc] initWithCapacity:decbCnt];
                for (int j=0; j<decbCnt; j++) {
                    WJCTableItemInfo *tempTableItem ;
                    if (j==0) {
                        tempTableItem = [WJCTableItemInfo tableItemInfoWithString:_descDealer.descTabs.items[_descDealer.combineIndexes.items[tInd].items[i]->index].items[j]->desc];
                        [_descTittleArray1 addObject:_descDealer.descTabs.items[_descDealer.combineIndexes.items[tInd].items[i]->index].items[j]->desc];
                    } else {
                        tempTableItem = [WJCTableItemInfo tableItemInfoWithDescItem:_descDealer.descTabs.items[_descDealer.combineIndexes.items[tInd].items[i]->index].items[j]];
                    }

                    [tempOneDescArr addObject:tempTableItem];
                }
                [_descArray addObject:tempOneDescArr];
            }
            
            NSInteger dispHexData = strtoul([dispValue UTF8String], 0, 16);
            int rLen = 0;
            for (int i=0; i<descSectionNum; i++) {
                int rlen2 = _descDealer.combineIndexes.items[tInd].items[i]->len;
                int valD = (dispHexData >> rLen) & (((int)(pow(2, rlen2))-1));
                _descArray[i][valD+1].isSeclected = YES;
                [_descTittleArray2 addObject:_descArray[i][valD+1].infoDesc];
                rLen = rLen + rlen2;
            }
            
            break;
        }
    }
}




#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (sectionNum);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section<5) {
        return 0;
    } else {
        NSInteger resultInt = 0;
        switch (self.editPara.descTypeEnum) {
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

    switch (section) {
        case 0:{
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:0.7];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 300 , 30)];
            label.text = [NSString stringWithFormat:@"min = %@ %@    max = %@ %@",_editPara.minStr,_editPara.symbol,_editPara.maxStr,_editPara.symbol];
            
            [view addSubview:label];
            return view;
            break;
        }
        case 1:{
            UIView *view = [[UIView alloc] init];
            //        view.backgroundColor = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:0.7];
            UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(5, 6, self.view.bounds.size.width-10, 33)];
            
            //判断参数类型，显示不同的键盘
            if (_editPara.isString) {
                text.keyboardType = UIKeyboardTypeASCIICapable;
            } else
                text.keyboardType = UIKeyboardTypeDecimalPad;
            
            text.borderStyle = UITextBorderStyleRoundedRect;
            text.font = [UIFont fontWithName:@"Arial" size:22.0f];
            text.returnKeyType = UIReturnKeyDone;
            
            //显示内容
            text.textAlignment = NSTextAlignmentCenter;
            text.text = dispValue;
            
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
            
            switch (self.editPara.descTypeEnum) {
                case DDT_NONE:{

                    break;
                }
                case DDT_NONE_BIT:{

                    if ([_dic objectForKey:[NSString stringWithFormat:@"%ld",section]]) {

                        imageView.image = [UIImage imageNamed:@"if_fold1"];
                    } else {

                        imageView.image = [UIImage imageNamed:@"if_unfold1"];
                    }
                    tittle = dispValue;
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
                    tittle = dispValue;
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
    switch (self.editPara.descTypeEnum) {
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
    if (indexPath.section>4) {
        switch (self.editPara.descTypeEnum) {
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
                switch (_editPara.len) {
                    case 1:
                        dispValue = [NSString stringWithFormat:@"%02X",tempDis];
                        break;
                    case 2:
                        dispValue = [NSString stringWithFormat:@"%04X",tempDis];
                        break;
                    case 4:
                        dispValue = [NSString stringWithFormat:@"%08X",tempDis];
                        break;
                    case 8:
                        dispValue = [NSString stringWithFormat:@"%16X",tempDis];
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
                dispValue = [NSString stringWithFormat:@"%d",_descArray[0][indexPath.row].val];
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
                switch (_editPara.len) {
                    case 1:
                        dispValue = [NSString stringWithFormat:@"%02X",tempDis];
                        break;
                    case 2:
                        dispValue = [NSString stringWithFormat:@"%04X",tempDis];
                        break;
                    case 4:
                        dispValue = [NSString stringWithFormat:@"%08X",tempDis];
                        break;
                    case 8:
                        dispValue = [NSString stringWithFormat:@"%16X",tempDis];
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
                
                int tInd = [_descDealer getDescIndexFromInd:self.editPara.index];
                
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
                    sPos = sPos + _descDealer.combineIndexes.items[tInd].items[i]->len;
                }
                switch (_editPara.len) {
                    case 1:
                        dispValue = [NSString stringWithFormat:@"%02X",val];
                        break;
                    case 2:
                        dispValue = [NSString stringWithFormat:@"%04X",val];
                        break;
                    case 4:
                        dispValue = [NSString stringWithFormat:@"%08X",val];
                        break;
                    case 8:
                        dispValue = [NSString stringWithFormat:@"%16X",val];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
