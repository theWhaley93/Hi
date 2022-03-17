//
//  ViewController.m
//  Hi
//
//  Created by apple on 2018/1/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import "WJCOneParameter.h"
#import "WJCHiFileExecutor.h"
#import "WJCOneParaViewCell.h"
#import "WJCOneGroup.h"
#import "WJCGroupItem.h"
#import "WJCParameters.h"
#import "WJCHiHexDealer.h"
#import "WJCHiCommunicator.h"
#import "WJCGlobalVariable.h"
#import "WJCGlobalConstants.h"
#import "WJCDescTabs.h"
#import "WJCDescIndexTabs.h"
#import "WJCDescCombineIndexTabs.h"
#import "WJCDescDealer.h"
#import "WJCDeviceFinder.h"
#import "WJCDevice.h"
#import "WJCCloudFiles.h"
#import "WJCCommonFunctions.h"
#import "WJCCfgFileListModel.h"
#import "WJCHiWorklist.h"
#import "WJCHiProject.h"



@interface ViewController ()<UITableViewDataSource,NSURLConnectionDelegate,NSURLSessionDataDelegate,WJCCloudDownFileDelegate>{
    Boolean t;
    NSDate *startT;
    NSDate *endT;
    UIActivityIndicatorView *indicator;
}
@property (nonatomic,strong)  NSMutableData *urlData;  //
@property (nonatomic,assign)  NSInteger *totalLength;  //
@property (weak, nonatomic) IBOutlet UITableView *parasTable;
@property (weak, nonatomic) IBOutlet UILabel *brooadcastIp;
@property (weak, nonatomic) IBOutlet UITextField *numText;

@property (weak, nonatomic) IBOutlet UITextField *infoText;
@property (nonatomic,strong)  NSArray *paraArray;  //参数数组

@property (nonatomic,strong)  WJCHiCommunicator *hiCom;  //hicom

@property (nonatomic,strong)  WJCDescTabs *testDescTabs;  //
@property (nonatomic,strong)  WJCDescIndexTabs *testDescIndexs;  //
@property (nonatomic,strong)  WJCDescCombineIndexTabs *testCombits;  //
@property (nonatomic,strong)  WJCDescDealer *testDescDealer;  //
@property (nonatomic,strong)  WJCDeviceFinder * tempDeviceFinder;
@property (nonatomic,strong)  WJCDevice *tempDevice;  //
@property (nonatomic,strong)  WJCHiWorklist *tempWorklist;  // 

@end

@implementation ViewController

- (NSString *)getStringValueFrom: (NSString *) wholeString :(NSString *)cutString{
    NSString *s1 = cutString;
    NSString *tempS1 = @"</";
    NSString *tempS2 = @"/>";
    NSString *s2 = [[tempS1 stringByAppendingString:cutString] stringByAppendingString:tempS2];
    NSRange range1 = [wholeString rangeOfString:s1];
    NSRange range2 = [wholeString rangeOfString:s2];
    if (range2.length>0) {
        NSRange range3 = NSMakeRange(range1.location+range1.length+2,range2.location-range1.location-range1.length-2);
        return [wholeString substringWithRange:range3];
    } else {
        return @"Not_Found";
    }


}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tempDevice = [[WJCDevice alloc] init];
    Boolean crB = [self.tempDevice createHiCom:@"192.168.1.1" OnPort:8899];
//    WJCAddrStruct abb;
//    abb.attribute = 0x61080;
//    abb.dataType = DT_DINT;
//    abb.res1 = 0;
//    abb.vDiv = 1;
//    abb.vMul = 1;
//    int aaaaaas = sizeof(abb);
//    Byte testBb[aaaaaas];
//    for (int i=0; i<aaaaaas; i++) {
//        testBb[i] = ((Byte *)(&abb))[i];
//    }
//    NSString *content = @"";
//    for (int i=0; i<4; i++) {
//        content = [content stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&abb.attribute))[i]]];
//    }
//    content = [content stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&abb.dataType))[0]]];
//    content = [content stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&abb.res1))[0]]];
//    for (int i=0; i<2; i++) {
//        content = [content stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&abb.vDiv))[i]]];
//    }
//    for (int i=0; i<2; i++) {
//        content = [content stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&abb.vMul))[i]]];
//    }
//    content = [content stringByAppendingString:@"0000"];
//    
//    NSString *tesAttr = WJCMakeAddrStructToString(abb);
    NSDate *startTim = [NSDate date];
    
    NSString *readstr2 = [self.tempDevice.hiCom readData:INV_MAXDESCTAB_INDEX subindex:0];
    NSString *readstr3 = [self.tempDevice.hiCom readData:INV_MAXDESCINDEX_INDEX subindex:0];
    NSString *readStr4 = [self.tempDevice.hiCom readData:INV_MAXCOMBINEINDEX_INDEX subindex:0];
    
    int indexTabI = strtoul([readstr3 UTF8String], 0, 16);
    int descTabI = strtoul([readstr2 UTF8String], 0, 16);
    int bitFieldTabI = strtoul([readStr4 UTF8String], 0, 16);
    
    self.tempDevice.descDealer = [[WJCDescDealer alloc] init];
    
    self.tempDevice.descDealer.descIndexes.items = [[NSMutableArray<WJCDescIndexItem *> alloc] initWithCapacity:indexTabI];
    for (uint16_t i=0; i<indexTabI; i++) {
        int pInd = 0;
        int dInd = 0;
        if (notErr([self.tempDevice.hiCom readDescIndexWithDescNumber:i withSubindex:0 paraIndex:&pInd descIndex:&dInd])) {
            WJCDescIndexItem *tempIndexItem = [[WJCDescIndexItem alloc] init];
            tempIndexItem->index = pInd;
            tempIndexItem->descIndex = dInd;
            [self.tempDevice.descDealer.descIndexes.items addObject:tempIndexItem];
        }
    }
    
    self.tempDevice.descDealer.descTabs.items = [[NSMutableArray<WJCDescTab *> alloc] initWithCapacity:descTabI];
    for (uint16_t i=0; i<descTabI; i++) {
        int oneDescCnt = 0;
        
        WJCDescTab * tempDescTab = [[WJCDescTab alloc] init];
        [self.tempDevice.descDealer.descTabs.items addObject:tempDescTab];
        
        NSString *oneDescReadStr = [_tempDevice.hiCom readDescCountWithDescIndex:i descCount:&oneDescCnt];
        
        self.tempDevice.descDealer.descTabs.items[i].items = [[NSMutableArray<WJCDescTabItem *> alloc]initWithCapacity:oneDescCnt];
        

        for (Byte j=0; j<oneDescCnt; j++) {
            int16_t tDescVal = 0;
            NSString * tDescStr;
            if (notErr([self.tempDevice.hiCom readOneDescWithDescTabIndex:i withDescTabSubindex:j descTabVal:&tDescVal descTabString:&tDescStr])) {
                WJCDescTabItem *tempDescTabItem = [[WJCDescTabItem alloc] init];
                tempDescTabItem->value = tDescVal;
                tempDescTabItem->desc = tDescStr;
                [self.tempDevice.descDealer.descTabs.items[i].items addObject:tempDescTabItem];
                
            }
        }

    }
    
    self.tempDevice.descDealer.combineIndexes.items = [[NSMutableArray<WJCDescBitFieldTabs *> alloc] initWithCapacity:bitFieldTabI];
    
    for (uint16_t i=0; i<bitFieldTabI; i++) {
        WJCDescBitFieldTabs *tempBitFieldTabs;
        if (notErr([self.tempDevice.hiCom readBitFieldTabsWithBitFieldIndex:i bitFieldTabs:&tempBitFieldTabs])) {
            [self.tempDevice.descDealer.combineIndexes.items addObject:tempBitFieldTabs];
        }
    }
    NSDate *endTim1 = [NSDate date];
    NSLog(@"%f",[endTim1 timeIntervalSinceDate:startTim]);
    
    NSString *readstr5 = [self.tempDevice.hiCom readData:INV_MAXGROUP_INDEX subindex:0];
    NSString *readstr6 = [self.tempDevice.hiCom readData:INV_MAXPARALIST_INDEX subindex:0];
    NSString *readstr7 = [self.tempDevice.hiCom readData:INV_CFGID_INDEX subindex:0];
    NSString *readStr8 = [self.tempDevice.hiCom readStringData:INV_CFGDESC_INDEX subindex:0];
    
    int groupCount = strtoul([readstr5 UTF8String], 0, 16);
    int paraCount = strtoul([readstr6 UTF8String], 0, 16);
    int cfgId = strtoul([readstr7 UTF8String], 0, 16);
    

    self.tempDevice.cfgId = cfgId;
    self.tempDevice.paras = [[WJCParameters alloc] init];
    self.tempDevice.paras.configId = cfgId;
    
    if (notErr(readStr8)) {
        self.tempDevice.paras.configDescription = readStr8;
    } else {
        self.tempDevice.paras.configDescription = @"无驱动器版本描述信息";
    }
    self.tempDevice.paras.actualGroup = [[NSMutableArray<WJCOneGroup *> alloc] initWithCapacity:groupCount];

    self.tempDevice.paras.paras = [[NSMutableArray<WJCOneParameter *> alloc] initWithCapacity:paraCount];
    
    
    WJCOneParameter *tempOneParaTest = [[WJCOneParameter alloc] init];
    for (int i = 0; i<paraCount; i++) {
        [self.tempDevice.paras.paras addObject:tempOneParaTest];
    }
    
    
    for (uint16_t i=0; i<groupCount; i++) {
        WJCOneGroup *tempOneGroup = [[WJCOneGroup alloc] init];
        //1.读组全称
        NSString *tempGroupFullName;
        NSString *readFullNameResult = [_tempDevice.hiCom readGroupFullNameWithUserLevel:0 withGroupIndex:i groupFullName:&tempGroupFullName];
        tempOneGroup.fullName = tempGroupFullName;
        //2.读组简称
        NSString *tempGroupShortName;
        NSString *readShortNameResult = [_tempDevice.hiCom readGroupShortNameWithUserLevel:0 withGroupIndex:i groupShortName:&tempGroupShortName];
        tempOneGroup.abbreviativeName = tempGroupShortName;
        //3.读组内容（组元素）
        NSMutableArray *tempGroupContent;
        NSString *tempGroupContentResult = [_tempDevice.hiCom readGroupContentWithUserLevel:0 withGroupIndex:i groupContent:&tempGroupContent];
        
        int tempGroupContentCount = tempGroupContent.count;
        tempOneGroup.items = [[NSMutableArray<WJCGroupItem *> alloc] initWithCapacity:tempGroupContentCount];
        tempOneGroup.visibleItems = [[NSMutableArray<WJCGroupItem *> alloc] init];
        //4.读组中每个元素信息
        for (int j=0; j<tempGroupContentCount; j++) {
            WJCGroupItem *tempGroupItem = [WJCGroupItem groupItemWithindex:[(NSNumber*)tempGroupContent[j] shortValue] name:[NSString stringWithFormat:@"%@%02d",tempOneGroup.abbreviativeName,j]];
            [tempOneGroup.items addObject:tempGroupItem];
            if ([(NSNumber*)tempGroupContent[j] shortValue] != 0) {
                [tempOneGroup.visibleItems addObject:tempGroupItem];
            }
            WJCOneParameter *tempOnePara = [[WJCOneParameter alloc] init];
            tempOnePara.index = [(NSNumber*)tempGroupContent[j] shortValue];
            
            if (tempOnePara.index != 0) {
                
                tempOnePara->groupIndex = i;
                tempOnePara->groupSubindex = j;
                tempOnePara.sDescribe = [NSString stringWithFormat:@"%@%02d",tempOneGroup.abbreviativeName,j];
                //4.1.读参数属性
                WJCAddrStruct tempParaAttrSuct;
                NSString *attrSuctResult = [_tempDevice.hiCom readParaAttributeWithIndex:tempOnePara.index withSubindex:0 attrStruct:&tempParaAttrSuct];
                tempOnePara->actData = tempParaAttrSuct;
                //4.2.读参数最大值
                NSMutableArray *tempMax;
                NSString *readMaxResult = [_tempDevice.hiCom readParaMaxWithIndex:tempOnePara.index withSubindex:0 maxData:&tempMax];
                for (int k=0; k<8; k++) {
                    tempOnePara->max[k] = [(NSNumber *)tempMax[k] intValue] ;
                }
                //4.3.读参数最小值
                NSMutableArray *tempMin;
                NSString *readMinResult = [_tempDevice.hiCom readParaMinWithIndex:tempOnePara.index withSubindex:0 minData:&tempMin];
                for (int k=0; k<8; k++) {
                    tempOnePara->min[k] = [(NSNumber *)tempMin[k] intValue] ;
                }
                //4.4.读参数默认值
                NSMutableArray *tempDefault;
                NSString *readDefaultResult = [_tempDevice.hiCom readParaDefaultWithIndex:tempOnePara.index withSubindex:0 defaultData:&tempDefault];
                for (int k=0; k<8; k++) {
                    tempOnePara->defaultVal[k] = [(NSNumber *)tempDefault[k] intValue] ;
                }
                //4.5.读参数描述
                NSString *tempParaDesc;
                NSString *readParaDescReault = [_tempDevice.hiCom readParaDescWithIndex:tempOnePara.index withSubindex:0 descbContent:&tempParaDesc];
                tempOnePara.lDescribe = tempParaDesc;
                //*4.6.读矩阵参数信息
                if (tempOnePara.isArray) {
                    uint16_t tempArrWid;
                    uint16_t tempArrLen;
                    NSString *readArrayInfo = [_tempDevice.hiCom readArrayParaInfoWithIndex:tempOnePara.index withSubindex:0 arrayWidth:&tempArrWid arrayLength:&tempArrLen];
                    tempOnePara->arrayWidth = tempArrWid;
                    tempOnePara->arrayLength = tempArrLen;
                } else {
                    tempOnePara->arrayWidth = 0;
                    tempOnePara->arrayLength = 0;
                }
                //4.7.初始化para内部信息
                [tempOnePara initReadHex];
                [tempOnePara initDefaultNewStr];
                [self.tempDevice.paras.paras replaceObjectAtIndex:tempOnePara.index withObject:tempOnePara];
            }

            
        }
        
        [self.tempDevice.paras.actualGroup addObject:tempOneGroup];
    }
    
    //创建生成标幺值的类
    self.tempDevice.perUnitValues  = [WJCPerUnitValues perUnitValueWithParas:self.tempDevice.paras];
    //创建生成驱动器状态类
    self.tempDevice.driverState = [WJCDriverState driverStateWithParas:self.tempDevice.paras];
    //创建工程管理器
    self.tempDevice.projectManger  = [[WJCHiProject alloc] initWithHiPara:self.tempDevice.paras];
    
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cfgPlstName = [NSString stringWithFormat:@"%@%d%@",@"CFGID",self.tempDevice.cfgId,@".plst"];  //@"CFGID98.plst"
    NSString *cfgDlstName = [NSString stringWithFormat:@"%@%d%@",@"CFGID",self.tempDevice.cfgId,@".dlst"];
    NSString *dlstSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/AddressListFiles/",cfgDlstName];
    
    NSString *plstSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/AddressListFiles/",cfgPlstName];
    
    NSDate *endTim2 = [NSDate date];
    NSLog(@"%f",[endTim2 timeIntervalSinceDate:endTim1]);
    
    NSString *plstContent = [_tempDevice.paras toString];//@"ces---";//
    Boolean plistSaveResult = [plstContent writeToFile:plstSavePath atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:NULL];
    
    NSString *dlstContent = [_tempDevice.descDealer toString];//
    Boolean dlistSaveResult = [dlstContent writeToFile:dlstSavePath atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:NULL];
    
    
    //---------------我是分割线----------------
    
    
    
    
    NSString *readstr8 = [self.tempDevice.hiCom readData:INV_MAXDESCINDEX_INDEX subindex:0];
    NSString *readStr9 = [self.tempDevice.hiCom readData:INV_MAXCOMBINEINDEX_INDEX subindex:0];
    
    
    NSString *readstr = [self.tempDevice.hiCom readData:4 subindex:0];
    int a = 0;
    int b = 0;
    readstr = [_tempDevice.hiCom readDescIndexWithDescNumber:0 withSubindex:0 paraIndex:&a descIndex:&b];
    int c = 0;
    readstr = [_tempDevice.hiCom readDescCountWithDescIndex:1 descCount:&c];
    NSString *testStt = @"";
    uint16_t d = 0;
    readstr = [_tempDevice.hiCom readOneDescWithDescTabIndex:0 withDescTabSubindex:0 descTabVal:&d descTabString:&testStt];
    readstr = [_tempDevice.hiCom readOneDescWithDescTabIndex:1 withDescTabSubindex:1 descTabVal:&d descTabString:&testStt];
    WJCDescBitFieldTabs * testtField ;//= [[WJCDescBitFieldTabs alloc] init];
    readstr = [_tempDevice.hiCom readBitFieldTabsWithBitFieldIndex:0 bitFieldTabs:&testtField];
    NSMutableArray * tabArr ;//= [[WJCDescBitFieldTabs alloc] init];
    readstr = [_tempDevice.hiCom readGroupContentWithUserLevel:0 withGroupIndex:0 groupContent:&tabArr];
    int e = [(NSNumber *)tabArr[1] intValue];
    NSString *tFul;
    NSString *tSho;
    readstr = [_tempDevice.hiCom readGroupFullNameWithUserLevel:0 withGroupIndex:0 groupFullName:&tFul];
    readstr = [_tempDevice.hiCom readGroupShortNameWithUserLevel:0 withGroupIndex:0 groupShortName:&tSho];
    NSMutableArray * maxT;
    readstr = [_tempDevice.hiCom readParaDefaultWithIndex:87 withSubindex:0 defaultData:&maxT];
    Byte max[8];
    for (int i=0; i<8; i++) {
        max[i] = [(NSNumber *)maxT[i] intValue];
    }
    
    NSString *descTe;
    readstr = [_tempDevice.hiCom readParaDescWithIndex:87 withSubindex:0 descbContent:&descTe];
    int f = 0;
    int g = 0;
    readstr = [_tempDevice.hiCom readArrayParaInfoWithIndex:180 withSubindex:0 arrayWidth:&f arrayLength:&g];
    WJCAddrStruct testType;
    readstr = [_tempDevice.hiCom readParaAttributeWithIndex:352 withSubindex:0 attrStruct:&testType];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    });
    
    [self.tempDevice loadFileWithCfgId:98];

    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *file = @"1519721501406-HI175bar_20180222-十一分厂.hiprj";
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@%@",documentPath,@"/",file];//[[NSBundle mainBundle] pathForResource:file ofType:nil];
    NSError *errorLis = nil;
    NSString *filecContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&errorLis];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    WJCHiProject *tempProject = [[WJCHiProject alloc] initWithHiPara:self.tempDevice.paras];
    [tempProject loadWithProjectFilePath:filePath];
    /*
    NSData *fileData1 = [[NSData alloc] init];
    Byte *testByte = (Byte *)[fileData1 bytes];
    uint pos = 0;

    uint32_t tLen = 0;
    [fileData getBytes:&tLen range:NSMakeRange(pos, 4)];
    pos = pos + 4;
    
//    uint32_t tLen = *((uint32_t *)byte1);
    Byte byte1[tLen] ;
    [fileData getBytes:byte1 range:NSMakeRange(pos, tLen)];
    pos = pos +tLen;
    
    NSData *data1 = [NSData dataWithBytes:byte1 length:tLen];
    NSString *data1str = [[NSString alloc] initWithData:data1 encoding:NSUTF16LittleEndianStringEncoding];
    
    
    [fileData getBytes:&tLen range:NSMakeRange(pos, 4)];
    pos = pos + 4;
    
    Byte byte2[tLen];
    [fileData getBytes:&byte2 range:NSMakeRange(pos, tLen)];
    pos = pos + tLen;
    
    NSData *data2 = [NSData dataWithBytes:byte2 length:tLen];
    NSString *data2str = [[NSString alloc] initWithData:data2 encoding:NSUTF16LittleEndianStringEncoding];
    
     */
    _tempWorklist = [WJCHiWorklist hiWorklistWithStr:filecContent withHiPara:self.tempDevice.paras];
    
    hiDevice = [[WJCDevice alloc] init];
    [hiDevice loadFileWithCfgId:98];
    NSLog(@"%@",hiDevice);
    
    
    WJCCfgFileListModel *tempList = [[WJCCfgFileListModel alloc] init];
    [tempList loadFromLocal:@""];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    
    
    self.urlData = [[NSMutableData alloc] init];
    NSString *ipA = [WJCDeviceFinder getBroadcastAddr];
    NSLog(@"%@",ipA);
    NSError *error2 = nil;
    NSString *str22 = [WJCHiFileExecutor openDlstFile:98 error:&error2];
    
    self.testDescDealer = [WJCDescDealer descDealerWithString:str22];
    
//    NSString *tpS = [WJCHiFileExecutor getTagetStringFrom:str22 cutString:@"descs"];
//    self.testDescTabs = [WJCDescTabs descTabsWithString:tpS];
//
//
//    NSString *tpDesInd = [WJCHiFileExecutor getTagetStringFrom:str22 cutString:@"indexs"];
//    self.testDescIndexs = [WJCDescIndexTabs descIndexTabsWithSring:tpDesInd];
//
//
//    NSString *tpComInd = [WJCHiFileExecutor getTagetStringFrom:str22 cutString:@"bits"];
//    self.testCombits = [WJCDescCombineIndexTabs descCombineIndexTabsWithString:tpComInd];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    globelMutexTest = [[NSObject alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    //131.07 3
    NSString *test2018 = [WJCHiHexDealer fixZero:@"0.41" radixPos:3 fix5:YES];
    NSLog(@"%@",test2018);
    
    NSString *t3;
    NSString *t = @"dhakhdkaj|daldjajl";
    NSArray *tre = [t componentsSeparatedByString:@"|"];
    NSRange trang = [t rangeOfString:tre[0]];
    NSString *ts = [t stringByReplacingOccurrencesOfString:tre[0] withString:@"ceshi" options:NSCaseInsensitiveSearch range:trang];
    WJCAddrStruct tempAddr = WJCMakeAddrStruct(@"801006000400010001000000");
    
    
/*
    NSString *home = NSHomeDirectory();
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AddressListFiles/CFGID55.plst" ofType:nil];
    NSError *error = nil;
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];//[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
 */
    NSError *error = nil;
    NSString *str = [WJCHiFileExecutor openPlstFile:98 error:&error];
    if (error) {
        NSLog(str);
    } else {
        NSLog(@"%@",str);
        NSString *s1 = @"addresscount";
        NSString *s2 = @"</addresscount/>";
        NSRange range1 = [str rangeOfString:@"addresscount"];
        NSRange range2 = [str rangeOfString:@"</addresscount/>"];
        NSRange range3 = NSMakeRange(range1.location+range1.length+2,range2.location-range1.location-range1.length-2);
        NSString *tempStr = [str substringWithRange:range3];
        NSLog(@"%@",tempStr);
        
        NSString *t2 = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"groupcount"];//[self getStringValueFrom:str :@"groupcount"];
        NSLog(@"%@",t2);
        //group6 dr;group1 AP
        t3 = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"group0"];//[self getStringValueFrom:str :@"group0"];
        NSLog(@"%@",t3);
        
        NSString *t4 = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"group"];//[self getStringValueFrom:str :@"group"];
        if (t4 == @"Not_Found") {
            NSLog(@"%@",t4);
        } else {
            NSLog(@"%@",t4);
        }
        NSString *t5 = [WJCHiFileExecutor getTagetStringFrom:t3 cutString:@"elements1"];//[self getStringValueFrom:str :@"group0"];
        NSLog(@"%@",t5);
        WJCOneParameter *one = [[WJCOneParameter alloc] initWithString:t5];
        NSLog(@"%@",one);
    }
    
    
    /*测试某一组
    WJCOneGroup *tempOneGroup = [WJCOneGroup oneGroupWithString:t3];
    NSLog(@"%@--%@",tempOneGroup.abbreviativeName,tempOneGroup.fullName);
    for (int i = 0; i<tempOneGroup.items.count; i++) {
        NSLog(@"%@---%d",((WJCGroupItem *)tempOneGroup.items[i])->abbreviativeName,((WJCGroupItem *)tempOneGroup.items[i])->index);
    }
    */
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    NSString *str2 = [WJCHiFileExecutor openPlstFile:98 error:&error];
    WJCParameters *testParas = [WJCParameters parametersWithString:str2];
    
    NSLog(@"%f",CFAbsoluteTimeGetCurrent()-start);
//    for (int i=0; i<testParas.paras.count; i++) {
//        NSLog(@"%@",testParas.paras[i]);
//    }
    

    
    
    int num = [[WJCHiFileExecutor getTagetStringFrom:t3 cutString:@"count"] intValue];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];//arrayWithCapacity:num];
    for (int i=0; i<num; i++) {
        NSString *tempEle = [NSString stringWithFormat:@"elements%d",i];
        WJCOneParameter *tempOne = [WJCOneParameter oneParameterWithString:[WJCHiFileExecutor getTagetStringFrom:t3 cutString:tempEle]];
        if (tempOne.index != 0 ) {
            [tempArray addObject:tempOne];
            NSLog(@"%@--%d--%@---%@---%d--%@--%@--%d--def:%f--%@--%@--min:%f--%@--%@--max:%f--%@--%@",tempOne.sDescribe,tempOne.index,tempOne.typeString,tempOne.attributeString,tempOne.radixPointPos,tempOne.symbol,tempOne.basedTypeString,tempOne.isReadonly,tempOne.defVal,tempOne.defHex,tempOne.defStr,tempOne.minVal,tempOne.minHex,tempOne.minStr,tempOne.maxVal,tempOne.maxHex,tempOne.maxStr);
        }
        
    }
    
    self.paraArray = [tempArray mutableCopy];
    


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
    return hiDevice.paras.actualGroup[0].visibleItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
     static NSString *identifier= @"car";
     WJCCarView *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
     if (cell == nil) {
     cell = [[[NSBundle mainBundle] loadNibNamed:@"CarView" owner:nil options:nil] firstObject];
     }
     */
    
    WJCOneParaViewCell *cell = [WJCOneParaViewCell oneParaViewCellWithTableView:tableView];
//    WJCCar *tempCar = self.carArray[indexPath.row];
    cell.descDealer = hiDevice.descDealer;
    cell.onePara = hiDevice.paras.paras[hiDevice.paras.actualGroup[0].visibleItems[indexPath.row]->index];

    //    [cell setCarView:tempCar];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)setTable{
    if (self->t) {
        self.parasTable.dataSource = self;
        self.parasTable.rowHeight = 52.5f;
        self->t = NO;
    } else {
                [self.parasTable reloadData];
//        NSArray *visibleCells = [self.parasTable indexPathsForVisibleRows];
//        [self.parasTable reloadData];
//        NSLog(@"%d",visibleCells.count);
//        for (int i=0; i<visibleCells.count; i++)
        {
//            [self.parasTable reloadRowsAtIndexPaths:visibleCells withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.parasTable reloadRowsAtIndexPaths:<#(nonnull NSArray<NSIndexPath *> *)#> withRowAnimation:<#(UITableViewRowAnimation)#>]
        }
//        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
//        [self.parasTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }

}

- (IBAction)connect:(id)sender {
    self.hiCom = [[WJCHiCommunicator alloc] init];
    [self.hiCom createAndConnectSocketOnIP:@"192.168.43.20" OnPort:8899];
    dispatch_queue_t queue = dispatch_queue_create("read", DISPATCH_QUEUE_SERIAL);

    dispatch_sync(queue, ^{
        for (int i = 0; i<self.paraArray.count; i++) {
            NSString *tempps = [self.hiCom readData:((WJCOneParameter *)(self.paraArray[i])).index subindex:0];
            [((WJCOneParameter *)(self.paraArray[i])) setValHexWithSubindex:0 withArrayIndex:0 val:tempps];
        }

    });
//    self.parasTable.dataSource = self;
//    self.parasTable.rowHeight = 52.5f;
}

- (void)showDeviceIps:(NSMutableArray<WJCWifiDeviceInfo*> *) devicesInfo{
    self.brooadcastIp.text = [WJCDeviceFinder getBroadcastAddr];
    self.numText.text = [NSString stringWithFormat:@"%d",devicesInfo.count];
}

- (void)searchDevice{
    NSString *ipA = [WJCDeviceFinder getBroadcastAddr];

    self.tempDeviceFinder = [WJCDeviceFinder deviceFinderWithIp:ipA];
    NSMutableArray *searchR = [self.tempDeviceFinder getWifiDevices];
    
    [self performSelectorOnMainThread:@selector(showDeviceIps:) withObject:searchR waitUntilDone:NO];
//    [self.brooadcastIp performSelectorOnMainThread:@selector(setText:) withObject:ipA waitUntilDone:NO];
//
//    [self.numText performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d",searchR.count] waitUntilDone:NO];
    
}



- (IBAction)testB:(id)sender {
//    self.hiCom = [[WJCHiCommunicator alloc] init];
//    [self.hiCom createAndConnectSocketOnIP:@"192.168.43.20" OnPort:8899];
//        self.parasTable.dataSource = self;
//        self.parasTable.rowHeight = 52.5f;
    [NSThread detachNewThreadSelector:@selector(searchDevice) toTarget:self withObject:nil];

//    NSString *ipA = [WJCDeviceFinder getBroadcastAddr];
//
////    NSLog(@"%@",ipA);
//    self.tempDeviceFinder = [WJCDeviceFinder deviceFinderWithIp:ipA];
//    NSMutableArray *searchR = [self.tempDeviceFinder getWifiDevices];
//
//    [self performSelectorOnMainThread:@selector(showDeviceIps:) withObject:searchR waitUntilDone:NO];
}


- (IBAction)test2B:(id)sender {
    
//    self.hiCom = [[WJCHiCommunicator alloc] init];
//    [self.hiCom createAndConnectSocketOnIP:@"192.168.43.20" OnPort:8899];
    [hiDevice createHiCom:@"192.168.43.20" OnPort:8899];
    /*
    self->t = YES;
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
        }

    }];
     */
//    [NSThread detachNewThreadWithBlock:^{
//        while (1) {
//            [self performSelectorOnMainThread:@selector(setTable) withObject:nil waitUntilDone:NO];
//            [NSThread sleepForTimeInterval:0.2f];
//        }
//    }];
//    [NSThread sleepForTimeInterval:3];
//    self.parasTable.dataSource = self;
//    self.parasTable.rowHeight = 52.5f;
}


- (Boolean)searchFileInDocumentsDir:(NSString *)fileName{
    Boolean test;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager * file = [NSFileManager defaultManager];
    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/AddressListFiles"];
    Boolean isExist = [file fileExistsAtPath:addressP];

    if (!isExist) {
        test = [file createDirectoryAtPath:addressP withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return isExist;
}

- (void)downloadFile{
    
    //NSString *home = NSHomeDirectory();
    
    /*
     NSURL *url = [NSURL URLWithString:@"http://101.37.83.8:8825/file/apiGetFiles?dirId=3"];
     NSData *rData = [NSData dataWithContentsOfURL:url];
     //    NSString *dStr = [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding];
     id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
     NSArray *array = (NSArray *)jsObject;
     
     NSURL *url2 = [NSURL URLWithString:@"http://101.37.83.8:80/fileupload/fileupload/1492130287434.plst"];
     NSData *rData2 = [NSData dataWithContentsOfURL:url2];
     
     NSString *st = [[NSString alloc] initWithData:rData2 encoding:NSUTF16LittleEndianStringEncoding];
     */
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://101.37.83.8:8825/file/apiGetFiles?dirId=3"];
    NSData *rData = [NSData dataWithContentsOfURL:url];

    id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
    NSArray<NSDictionary *> *array = (NSArray *)jsObject;
    
    for ( NSDictionary *dict in array) {
        if ([dict[@"fileName"] isEqualToString:@"CFGID98.plst"]) {
           
            NSString *u1 = @"http://101.37.83.8:80";
            NSString *dUrl = [NSString stringWithFormat:@"%@%@",u1,dict[@"fileUrl"]];
            NSURL *downUrl = [NSURL URLWithString:dUrl];
            self->startT = [NSDate date];
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            
            NSURLSessionDataTask *task = [session dataTaskWithURL:downUrl];
            [task resume];
            
            /*
            NSData *rData2 = [NSData dataWithContentsOfURL:downUrl];//NSUTF16LittleEndianStringEncoding
            NSString *str = [[NSString alloc] initWithData:rData2 encoding:NSUTF16LittleEndianStringEncoding];
            NSError *err = nil;
            self->endT = [NSDate date];
            NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
            NSString *savePath = [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],@"/AddressListFiles/CFGID98.plst"];
            [str writeToFile:savePath atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:&err];
            if (!err) {
                NSLog(@"保存成功");
            } else {
                NSLog(@"保存失败 err is %@",err.localizedDescription);
            }
            */
            /*
            NSURL *downUrl = [NSURL URLWithString:dUrl];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downUrl];
            
            NSURLSession *seesion = [NSURLSession sharedSession];
            
            NSURLSessionDownloadTask *downloadTask = [seesion downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (!error) {
                    NSError * saveError = nil;
                    NSString *savePath = [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],@"/AddressListFiles/CFGID99.plst"];
                    NSURL *saveUrl = [NSURL fileURLWithPath:savePath];
                    
                    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&saveError];
                    if (!saveError) {
                        NSLog(@"保存成功");
                    } else {
                        NSLog(@"保存失败");
                    }
                } else {
                    NSLog(@"error is %@",error.localizedDescription);
                }
            }];
            
            [downloadTask resume];
            */
            break;
        }
    }
    
    
}
- (Boolean)searchForLocal:(int)rCfgId{
//    Boolean localRes = false;
    
    //先判断有没有AddressListFiles文件夹
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager * file = [NSFileManager defaultManager];
    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/AddressListFiles"];
    Boolean isExist = [file fileExistsAtPath:addressP];
    
    if (!isExist) {//如果没有，创建
        [file createDirectoryAtPath:addressP withIntermediateDirectories:YES attributes:nil error:nil];
        return NO;
    }
    
    NSString *cfgPlstPath = [NSString stringWithFormat:@"%@%@%@",addressP,@"/",[NSString stringWithFormat:@"%@%d%@",@"CFGID",rCfgId,@".plst"]];  //@"CFGID98.plst"
    NSString *cfgDlstPath = [NSString stringWithFormat:@"%@%@%@",addressP,@"/",[NSString stringWithFormat:@"%@%d%@",@"CFGID",rCfgId,@".dlst"]];
    
    if (([file fileExistsAtPath:cfgPlstPath]) && ([file fileExistsAtPath:cfgDlstPath])) {
        return YES;
    }
    return NO;
    
}

-(void)readIn{
    NSString *tempps = [hiDevice.hiCom readData:4 subindex:0];
    NSLog(@"%@",tempps);
}

- (IBAction)downloadCfgFile:(id)sender {


    
//    [NSThread detachNewThreadWithBlock:^{
//        NSString *tempps = [hiDevice.hiCom readData:4 subindex:0];
//        NSLog(@"%@---%@",tempps,[NSThread currentThread]);
//    }];

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *recString = COMM_TIMEOUT;
        int retryTimes = 0;

        while ((retryTimes <5) && (isErr(recString))) {
            recString = [hiDevice.hiCom readData:4 subindex:0];
            retryTimes++;
        }

        NSLog(@"%@--times:%d-%@",recString,retryTimes,[NSThread currentThread]);
        if (isErr(recString)) {

        } else {
            
            int recD = strtoul([recString UTF8String], 0, 16);
            if ([self searchForLocal:recD]) {
                NSLog(@"本地存在CFGD%d版本参数",recD);
            } else {
                
                [indicator performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
//                [indicator startAnimating];
                WJCCloudFiles *tempCloud = [[WJCCloudFiles alloc] initWithDelegate:self];
//                [tempCloud setTimeOut];
                [tempCloud startDownload:recD];
            }
            

        
        }
    });

//    [self.urlData resetBytesInRange:NSMakeRange(0, (self.urlData).length)];
//    [self.urlData setLength:0];
//    [self searchFileInDocumentsDir:@""];
//    [self downloadFile];
    /*
    NSString *file = [NSString stringWithFormat:@"%@%d%@",@"AddressListFiles/CFGID",98,@".plst"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    NSError *error = nil;
    NSString *filecContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
    
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];
    //沙盒目录
    NSLog(@"%@",NSHomeDirectory());
    //myapp.app
    NSLog(@"%@",[[NSBundle mainBundle] bundlePath]);
    //documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];//[paths objectAtIndex:0];
    NSLog(@"%@",docPath);
    //library
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libPath = [paths2 objectAtIndex:0];
    NSLog(@"%@",libPath);
    
    NSString * temp  = [NSString stringWithFormat:@"hello world"];
    NSString *testWriteFile = [NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle] bundlePath],@"/test",@".txt"];
    NSError * err = nil;
    Boolean b = [temp writeToFile:testWriteFile atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"写入bundle失败");
    } else {
        NSLog(@"写入buldle成功");
    }

    NSString *testWriteFile2 = [NSString stringWithFormat:@"%@%@%@",NSHomeDirectory(),@"/test",@".txt"];
    NSError * err2 = nil;
    Boolean b2 = [temp writeToFile:testWriteFile2 atomically:YES encoding:NSUTF8StringEncoding error:&err2];
    if (err2) {
        NSLog(@"写入沙盒失败");
    } else {
        NSLog(@"写入沙盒成功");
    }
    
    NSString *testWriteFile3 = [NSString stringWithFormat:@"%@%@%@",docPath,@"/test",@".txt"];
    NSError * err3 = nil;
    Boolean b3 = [temp writeToFile:testWriteFile3 atomically:YES encoding:NSUTF8StringEncoding error:&err3];
    if (err3) {
        NSLog(@"写入document失败");
    } else {
        NSLog(@"写入document成功");
    }
    
    NSString *testWriteFile4 = [NSString stringWithFormat:@"%@%@%@",libPath,@"/test",@".txt"];
    NSError * err4 = nil;
    Boolean b4 = [temp writeToFile:testWriteFile4 atomically:YES encoding:NSUTF8StringEncoding error:&err4];
    if (err4) {
        NSLog(@"写入lib失败");
    } else {
        NSLog(@"写入lib.成功");
    }
    */
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
    self.totalLength = response.expectedContentLength;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.urlData appendData:data];
    
    NSInteger nowlength = self.urlData.length;
    NSLog(@"%d",data.length);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%@",[NSThread currentThread]);
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    destPath = [destPath stringByAppendingString:@"/test.plst"];
    self->endT = [NSDate date];
    NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
    NSFileManager *manger = [NSFileManager defaultManager];
    Boolean isDownLoad = [manger createFileAtPath:destPath contents:self.urlData attributes:nil];
    
    if (isDownLoad) {
        NSLog(@"ok");
    }else{
        NSLog(@"sorry");
    }
}
- (void)testD:(NSInteger)te{
    NSLog(@"%d",te);
}

- (void)downLoadCfgFileResult:(Boolean)rResult downResult:(WJCDownLoadResult)rDownResult{
    if (rResult) {
        NSLog(@"成功");
        NSLog(@"%d",rDownResult);
        [indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           // UI更新代码
           [self presentViewController:alert animated:YES completion:nil];
        });
    } else {
        NSLog(@"%d",rDownResult);
                [indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:okAlert];
        dispatch_async(dispatch_get_main_queue(), ^{
           // UI更新代码
           [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

@end
