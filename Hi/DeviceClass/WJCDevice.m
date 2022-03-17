//
//  WJCDevice.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDevice.h"
#import "WJCHiFileExecutor.h"

WJCDevice *hiDevice;
@implementation WJCDevice



/** 文件载入
 */
- (Boolean)loadFileWithCfgId:(NSInteger)cfgid{
    Boolean resultB = NO;
    NSError *error = nil;
    NSString *plstStr = [WJCHiFileExecutor openPlstFile:cfgid error:&error];
    if (error) {
        return resultB;
    } else {
        _paras = [WJCParameters parametersWithString:plstStr];
        
        //创建生成标幺值的类
        _perUnitValues = [WJCPerUnitValues perUnitValueWithParas:_paras];
        //创建生成驱动器状态类
        _driverState = [WJCDriverState driverStateWithParas:_paras];
        
        NSError *error2 = nil;
        NSString *dlstStr = [WJCHiFileExecutor openDlstFile:cfgid error:&error2];
        if (error2) {
            return resultB;
        } else {
            _descDealer = [WJCDescDealer descDealerWithString:dlstStr];
            
            _projectManger  = [[WJCHiProject alloc] initWithHiPara:_paras];
            resultB = YES;
        }
    }
    return resultB;
}

- (Boolean)createHiCom:(NSString *) ip OnPort:(uint16_t)port{
    self.hiCom = [[WJCHiCommunicator alloc] init];
    self.connectedIP = ip;
    return [self.hiCom createAndConnectSocketOnIP:ip OnPort:8899];
    
}

/** 参数文件在线更新
 */
- (Boolean)updateCfgFile{
    NSDate *startTim = [NSDate date];

    /**代理动作
     */
    if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
    {
        
        [theDelegate updateCfgFileResult:YES updateState:UPDATE_UPDATING updateInfo:@"更新固化参数" updateProgress:0];
        
    }
    
    NSString *readstr2 = [self.hiCom readData:INV_MAXDESCTAB_INDEX subindex:0];
    NSString *readstr3 = [self.hiCom readData:INV_MAXDESCINDEX_INDEX subindex:0];
    NSString *readStr4 = [self.hiCom readData:INV_MAXCOMBINEINDEX_INDEX subindex:0];
    
    NSString *readstr5 = [self.hiCom readData:INV_MAXGROUP_INDEX subindex:0];
    NSString *readstr6 = [self.hiCom readData:INV_MAXPARALIST_INDEX subindex:0];
    NSString *readstr7 = [self.hiCom readData:INV_CFGID_INDEX subindex:0];
    NSString *readStr8 = [self.hiCom readStringData:INV_CFGDESC_INDEX subindex:0];
    
    if ((isErr(readstr5)) || (isErr(readstr6)) || (isErr(readstr7)) || (isErr(readStr8)) || (isErr(readstr2)) || (isErr(readstr3)) || (isErr(readStr4))) {
        /**代理动作
         */
        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
        {
            
            [theDelegate updateCfgFileResult:NO updateState:UPDATE_UPDATING updateInfo:@"更新固化参数失败" updateProgress:0];
            
        }
        return NO;
    }
    
    int indexTabI = strtoul([readstr3 UTF8String], 0, 16);
    int descTabI = strtoul([readstr2 UTF8String], 0, 16);
    int bitFieldTabI = strtoul([readStr4 UTF8String], 0, 16);
    
    int groupCount = strtoul([readstr5 UTF8String], 0, 16);
    int paraCount = strtoul([readstr6 UTF8String], 0, 16);
    int cfgId = strtoul([readstr7 UTF8String], 0, 16);
    
    int allParasP = indexTabI +descTabI + bitFieldTabI + groupCount+ paraCount;
    int nowP = 0;
    float nowPrc ;
    //一。更新描述文件

    
    self.descDealer = [[WJCDescDealer alloc] init];
    
    self.descDealer.descIndexes.items = [[NSMutableArray<WJCDescIndexItem *> alloc] initWithCapacity:indexTabI];
    for (uint16_t i=0; i<indexTabI; i++) {
        int pInd = 0;
        int dInd = 0;
        if (notErr([self.hiCom readDescIndexWithDescNumber:i withSubindex:0 paraIndex:&pInd descIndex:&dInd])) {
            WJCDescIndexItem *tempIndexItem = [[WJCDescIndexItem alloc] init];
            tempIndexItem->index = pInd;
            tempIndexItem->descIndex = dInd;
            [self.descDealer.descIndexes.items addObject:tempIndexItem];
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                nowPrc = (float)(++nowP) /allParasP;
                [theDelegate updateCfgFileResult:YES updateState:UPDATE_UPDATING updateInfo:[NSString stringWithFormat:@"更新描述索引列表%d",i] updateProgress:nowPrc];
                
            }
        }
        else{
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                nowPrc = (float)(++nowP) /allParasP;
                [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新描述索引列表%d失败",i] updateProgress:nowPrc];
                
            }
            return NO;
        }
    }
    
    self.descDealer.descTabs.items = [[NSMutableArray<WJCDescTab *> alloc] initWithCapacity:descTabI];
    for (uint16_t i=0; i<descTabI; i++) {
        int oneDescCnt = 0;
        
        WJCDescTab * tempDescTab = [[WJCDescTab alloc] init];
        [self.descDealer.descTabs.items addObject:tempDescTab];
        
        NSString *oneDescReadStr = [self.hiCom readDescCountWithDescIndex:i descCount:&oneDescCnt];
        if (isErr(oneDescReadStr)) {
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新描述列表%d失败",i] updateProgress:nowPrc];
                
            }
            return NO;
        }
        /**代理动作
         */
        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
        {
            nowPrc = (float)(++nowP) /allParasP;
            [theDelegate updateCfgFileResult:YES updateState:UPDATE_UPDATING updateInfo:[NSString stringWithFormat:@"更新描述列表%d",i] updateProgress:nowPrc];
            
        }
        self.descDealer.descTabs.items[i].items = [[NSMutableArray<WJCDescTabItem *> alloc]initWithCapacity:oneDescCnt];
        
        
        for (Byte j=0; j<oneDescCnt; j++) {
            int16_t tDescVal = 0;
            NSString * tDescStr;
            
            if (notErr([self.hiCom readOneDescWithDescTabIndex:i withDescTabSubindex:j descTabVal:&tDescVal descTabString:&tDescStr])) {
                WJCDescTabItem *tempDescTabItem = [[WJCDescTabItem alloc] init];
                tempDescTabItem->value = tDescVal;
                tempDescTabItem->desc = tDescStr;
                [self.descDealer.descTabs.items[i].items addObject:tempDescTabItem];
                
            } else {
                /**代理动作
                 */
                if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                {
                    [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新描述列表%d失败",i] updateProgress:nowPrc];
                    
                }
                return NO;
            }
        }
        
    }
    
    self.descDealer.combineIndexes.items = [[NSMutableArray<WJCDescBitFieldTabs *> alloc] initWithCapacity:bitFieldTabI];
    
    for (uint16_t i=0; i<bitFieldTabI; i++) {
        WJCDescBitFieldTabs *tempBitFieldTabs;
        if (notErr([self.hiCom readBitFieldTabsWithBitFieldIndex:i bitFieldTabs:&tempBitFieldTabs])) {
            [self.descDealer.combineIndexes.items addObject:tempBitFieldTabs];
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                nowPrc = (float)(++nowP) /allParasP;
                [theDelegate updateCfgFileResult:YES updateState:UPDATE_UPDATING updateInfo:[NSString stringWithFormat:@"更新位描述索引列表%d",i] updateProgress:nowPrc];
                
            }
        } else {
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新描述索引列表%d失败",i] updateProgress:nowPrc];
                
            }
            return NO;
        }
    }
    NSDate *endTim1 = [NSDate date];
    NSLog(@"%f",[endTim1 timeIntervalSinceDate:startTim]);
    
    
    //二。更新参数信息

    
    self.cfgId = cfgId;
    self.paras = [[WJCParameters alloc] init];
    self.paras.configId = cfgId;
    
    if (notErr(readStr8)) {
        self.paras.configDescription = readStr8;
    } else {
        self.paras.configDescription = @"无驱动器版本描述信息";
    }
    
    self.paras.actualGroup = [[NSMutableArray<WJCOneGroup *> alloc] initWithCapacity:groupCount];
    
    self.paras.paras = [[NSMutableArray<WJCOneParameter *> alloc] initWithCapacity:paraCount];
    
    
    WJCOneParameter *tempOneParaTest = [[WJCOneParameter alloc] init];
    for (int i = 0; i<paraCount; i++) {
        [self.paras.paras addObject:tempOneParaTest];
    }
    
    
    for (uint16_t i=0; i<groupCount; i++) {
        WJCOneGroup *tempOneGroup = [[WJCOneGroup alloc] init];
        //1.读组全称
        NSString *tempGroupFullName;
        NSString *readFullNameResult = [self.hiCom readGroupFullNameWithUserLevel:0 withGroupIndex:i groupFullName:&tempGroupFullName];
        if (isErr(readFullNameResult)) {
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                
                [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新第%d组参数失败",i] updateProgress:nowPrc];
                
            }
            return NO;
        }
        tempOneGroup.fullName = tempGroupFullName;
        //2.读组简称
        NSString *tempGroupShortName;
        NSString *readShortNameResult = [self.hiCom readGroupShortNameWithUserLevel:0 withGroupIndex:i groupShortName:&tempGroupShortName];
        if (isErr(readShortNameResult)) {
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                
                [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新第%d组参数失败",i] updateProgress:nowPrc];
                
            }
            return NO;
        }
        /**代理动作 正常
         */
        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
        {
            nowPrc = (float)(++nowP) /allParasP;
            [theDelegate updateCfgFileResult:YES updateState:UPDATE_UPDATING updateInfo:[NSString stringWithFormat:@"更新%@组参数",tempGroupShortName] updateProgress:nowPrc];
            
        }
        tempOneGroup.abbreviativeName = tempGroupShortName;
        //3.读组内容（组元素）
        NSMutableArray *tempGroupContent;
        NSString *tempGroupContentResult = [self.hiCom readGroupContentWithUserLevel:0 withGroupIndex:i groupContent:&tempGroupContent];
        if (isErr(tempGroupContentResult)) {
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
                
                [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@组参数失败",tempGroupShortName] updateProgress:nowPrc];
                
            }
            return NO;
        }
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
            tempOnePara.sDescribe = [NSString stringWithFormat:@"%@%02d",tempOneGroup.abbreviativeName,j];
            /**代理动作
             */
            if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
            {
//                if (tempGroupContentCount>=20) {
//                    if (++nowP >= 20) {
//
//                    } else {
//                        nowPrc = (float)(++nowP) /allParasP;
//                    }
//                } else {
//                    if (++nowP >= (tempGroupContentCount-1)) {
//                        nowPrc = (float)(nowP+(20-tempGroupContentCount)) /allParasP;
//                    } else {
//                        nowPrc = (float)(++nowP) /allParasP;
//                    }
//
//                }

                nowPrc = (float)(++nowP) /allParasP;
                [theDelegate updateCfgFileResult:YES updateState:UPDATE_UPDATING updateInfo:[NSString stringWithFormat:@"更新%@参数",tempOnePara.sDescribe] updateProgress:nowPrc];
                
            }
            if (tempOnePara.index != 0) {
                
                tempOnePara->groupIndex = i;
                tempOnePara->groupSubindex = j;
                

                //4.1.读参数属性
                WJCAddrStruct tempParaAttrSuct;
                NSString *attrSuctResult = [self.hiCom readParaAttributeWithIndex:tempOnePara.index withSubindex:0 attrStruct:&tempParaAttrSuct];
                if (isErr(tempGroupContentResult)) {
                    /**代理动作
                     */
                    if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                    {
                        
                        [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@参数失败",tempOnePara.sDescribe] updateProgress:nowPrc];
                        
                    }
                    return NO;
                }
                tempOnePara->actData = tempParaAttrSuct;
                //4.2.读参数最大值
                NSMutableArray *tempMax;
                NSString *readMaxResult = [self.hiCom readParaMaxWithIndex:tempOnePara.index withSubindex:0 maxData:&tempMax];
                if (isErr(readMaxResult)) {
                    /**代理动作
                     */
                    if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                    {
                        
                        [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@参数失败",tempOnePara.sDescribe] updateProgress:nowPrc];
                        
                    }
                    return NO;
                }
                for (int k=0; k<8; k++) {
                    tempOnePara->max[k] = [(NSNumber *)tempMax[k] intValue] ;
                }
                //4.3.读参数最小值
                NSMutableArray *tempMin;
                NSString *readMinResult = [self.hiCom readParaMinWithIndex:tempOnePara.index withSubindex:0 minData:&tempMin];
                if (isErr(readMinResult)) {
                    /**代理动作
                     */
                    if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                    {
                        
                        [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@参数失败",tempOnePara.sDescribe] updateProgress:nowPrc];
                        
                    }
                    return NO;
                }
                for (int k=0; k<8; k++) {
                    tempOnePara->min[k] = [(NSNumber *)tempMin[k] intValue] ;
                }
                //*4.4.读参数默认值
                if (tempOnePara.isReadonly) {
                    for (int k=0; k<8; k++) {
                        tempOnePara->defaultVal[k] = 0 ;
                    }
                } else {
                    NSMutableArray *tempDefault;
                    NSString *readDefaultResult = [self.hiCom readParaDefaultWithIndex:tempOnePara.index withSubindex:0 defaultData:&tempDefault];
                    if (isErr(readDefaultResult)) {
                        /**代理动作
                         */
                        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                        {
                            
                            [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@参数失败",tempOnePara.sDescribe] updateProgress:nowPrc];
                            
                        }
                        return NO;
                    }
                    for (int k=0; k<8; k++) {
                        tempOnePara->defaultVal[k] = [(NSNumber *)tempDefault[k] intValue] ;
                    }
                }

                //4.5.读参数描述
                NSString *tempParaDesc;
                NSString *readParaDescReault = [self.hiCom readParaDescWithIndex:tempOnePara.index withSubindex:0 descbContent:&tempParaDesc];
                if (isErr(readParaDescReault)) {
                    /**代理动作
                     */
                    if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                    {
                        
                        [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@参数失败",tempOnePara.sDescribe] updateProgress:nowPrc];
                        
                    }
                    return NO;
                }
                tempOnePara.lDescribe = tempParaDesc;
                //*4.6.读矩阵参数信息
                if (tempOnePara.isArray) {
                    uint16_t tempArrWid;
                    uint16_t tempArrLen;
                    NSString *readArrayInfo = [self.hiCom readArrayParaInfoWithIndex:tempOnePara.index withSubindex:0 arrayWidth:&tempArrWid arrayLength:&tempArrLen];
                    if (isErr(readArrayInfo)) {
                        /**代理动作
                         */
                        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
                        {
                            
                            [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:[NSString stringWithFormat:@"更新%@参数失败",tempOnePara.sDescribe] updateProgress:nowPrc];
                            
                        }
                        return NO;
                    }
                    tempOnePara->arrayWidth = tempArrWid;
                    tempOnePara->arrayLength = tempArrLen;
                } else {
                    tempOnePara->arrayWidth = 0;
                    tempOnePara->arrayLength = 0;
                }
                //4.7.初始化para内部信息
                [tempOnePara initReadHex];
                [tempOnePara initDefaultNewStr];
                [self.paras.paras replaceObjectAtIndex:tempOnePara.index withObject:tempOnePara];
            }
            
            
        }
        
        [self.paras.actualGroup addObject:tempOneGroup];
    }
    
    //创建生成标幺值的类
    self.perUnitValues  = [WJCPerUnitValues perUnitValueWithParas:self.paras];
    //创建生成驱动器状态类
    self.driverState = [WJCDriverState driverStateWithParas:self.paras];
    //创建工程管理器
    self.projectManger  = [[WJCHiProject alloc] initWithHiPara:self.paras];
    
    
    //三。存成文件
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cfgPlstName = [NSString stringWithFormat:@"%@%d%@",@"CFGID",self.cfgId,@".plst"];  //@"CFGID98.plst"
    NSString *cfgDlstName = [NSString stringWithFormat:@"%@%d%@",@"CFGID",self.cfgId,@".dlst"];
    NSString *dlstSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/AddressListFiles/",cfgDlstName];
    
    NSString *plstSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/AddressListFiles/",cfgPlstName];
    
    NSDate *endTim2 = [NSDate date];
    NSLog(@"%f",[endTim2 timeIntervalSinceDate:endTim1]);
    
    NSString *plstContent = [self.paras toString];//@"ces---";//
    Boolean plistSaveResult = [plstContent writeToFile:plstSavePath atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:NULL];
    if (!plistSaveResult) {
        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
        {
            
            [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:@"生成plst文件失败" updateProgress:1];
            
        }
        return NO;
    }
    
    NSString *dlstContent = [self.descDealer toString];//
    Boolean dlistSaveResult = [dlstContent writeToFile:dlstSavePath atomically:YES encoding:NSUTF16LittleEndianStringEncoding error:NULL];
    if (!dlistSaveResult) {
        if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
        {
            
            [theDelegate updateCfgFileResult:NO updateState:UPDATE_FAIL updateInfo:@"生成dlst文件失败" updateProgress:1];
            
        }
        return NO;
    }
    
    if ([theDelegate respondsToSelector:@selector(updateCfgFileResult:updateState:updateInfo:updateProgress:)])
    {
        
        [theDelegate updateCfgFileResult:YES updateState:UPDATE_SUCC updateInfo:@"更新完成" updateProgress:1];
        
    }
    
    return YES;
}

@end
