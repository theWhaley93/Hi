//
//  WJCHiWorklist.m
//  Hi
//
//  Created by apple on 2018/4/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCHiWorklist.h"
#import "WJCHiFileExecutor.h"
#import "WJCGlobalConstants.h"
#import "WJCCommonFunctions.h"


/**************************************
 单个worklist item的内容
 **************************************/
@implementation WJCHiWorklistItem



#pragma mark - 初始化动作

- (void)initOldVerOffline{
    
    offlineVal = @"";
    
    if (_nowPara.isDataSet) {
        offlineVal = @"|";
    }
    
    if (_nowPara.isArray) {
        NSString *tempArrStr = @"";
        for (int i=0; i<_nowPara.arrayCount-1; i++) {
            tempArrStr = [tempArrStr stringByAppendingString:@","];
        }
        
        if (_nowPara.isDataSet) {
            offlineVal = [[tempArrStr stringByAppendingString:offlineVal] stringByAppendingString:tempArrStr];
        } else {
            offlineVal = tempArrStr;
        }
    }
    
}

- (instancetype)initWithIndex:(int)rIndex withSname:(NSString*)rSname withHiPara:(WJCParameters*)rPara{
    
    if (self = [super init]) {
        _index = rIndex;
        _sName = rSname;
        _nowPara = rPara.paras[rIndex];
        [self initOldVerOffline];
    }
    return self;
}


+ (instancetype)hiWorklistItemWithIndex:(int)rIndex withSname:(NSString*)rSname withHiPara:(WJCParameters*)rPara{
    return [[WJCHiWorklistItem alloc] initWithIndex:rIndex withSname:rSname withHiPara:rPara];
}

- (instancetype)initWithString:(NSString*)rStr withHiPara:(WJCParameters*)rPara{
    if (self = [super init]) {
        
        NSString *indexStr = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"index"];
        _index = [indexStr intValue];
        _sName = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"sdesc"];;
//        _nowPara = rPara.paras[_index];
        
        _nowPara = [rPara getOneParaWithIndex:_index];
        if ((_nowPara == nil) || (_nowPara.index == 0)) {
            return nil;
        }
        
        [self initOldVerOffline];
        
        NSString *oldVerOffline = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"offlineval"];
        
        NSString *newVerOffline = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"offlineval00"];
        
        if ([newVerOffline isEqualToString:NOT_FOUND]) {
            [self setOfflineStrValWithSubindex:0 withArrayIndex:0 withStrVal:oldVerOffline];
        } else
            offlineVal = newVerOffline;
        
        
    }
    return self;
//    actData = WJCMakeAddrStruct([WJCHiFileExecutor getTagetStringFrom:str cutString:@"attr"]);
//    self.index = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"index"] intValue];
}

+ (instancetype)hiWorklistItemWithString:(NSString*)rStr withHiPara:(WJCParameters*)rPara{
    return [[WJCHiWorklistItem alloc] initWithString:rStr withHiPara:rPara];
}
#pragma mark - 生成string
- (NSString *)worklistItemToString{
    NSString *contentStr = @"";
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:WJCMakeAddrStructToString(_nowPara->actData) withTittleString:@"attr"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",_nowPara.index] withTittleString:@"index"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:@"0" withTittleString:@"gindex"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:@"0" withTittleString:@"gsubindex"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_sName withTittleString:@"sdesc"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_nowPara.lDescribe withTittleString:@"ldesc"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[self offlineStrValWithSubindex:0 withArrayIndex:0] withTittleString:@"offlineval"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",_nowPara->arrayWidth] withTittleString:@"ArrayWidth"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",_nowPara->arrayLength]  withTittleString:@"ArrayLength"]];
    
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_nowPara.maxHexString withTittleString:@"max"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_nowPara.minHexString withTittleString:@"min"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_nowPara.defHexString withTittleString:@"defaultVal"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:@"" withTittleString:@"readhex"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_nowPara.usedReadHex withTittleString:@"readhex00"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:self->offlineVal withTittleString:@"offlineval00"]];
    return contentStr;
}
#pragma mark - 离线值的读取写入动作

//显示的离线值读取
- (NSString*)offlineStrValWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd{
    NSString *temps = @"";
    if ((! _nowPara.isArray) && (! _nowPara.isDataSet)) {
        //互斥锁
        @synchronized(self){
            temps = offlineVal;
        }
        
    } else if ((_nowPara.isDataSet) && (!_nowPara.isArray)){
        @synchronized(self){
            NSArray *arrStr = [offlineVal componentsSeparatedByString:@"|"];
            temps = arrStr[rSubind];
        }
    } else if ((_nowPara.isDataSet) && (_nowPara.isArray)){
        @synchronized(self){
            NSArray *dataSetAndArrayStr= [offlineVal componentsSeparatedByString:@"|"];
            NSArray *arrayStr = [dataSetAndArrayStr[rSubind] componentsSeparatedByString:@","];
            temps = arrayStr[rArrInd];
        }
    } else if ((!_nowPara.isDataSet) && (_nowPara.isArray)) {
        @synchronized(self){
            NSArray *arrStr = [offlineVal componentsSeparatedByString:@","];
            temps = arrStr[rArrInd];
        }
    }
    
    return temps;
}
//显示的离线设定
- (void)setOfflineStrValWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd withStrVal:(NSString *)rStrVal{
    if ((! _nowPara.isArray) && (! _nowPara.isDataSet)) { //普通参数
        //互斥锁
        @synchronized(self){
            offlineVal = rStrVal;
        }
        
    } else if ((_nowPara.isDataSet) && (!_nowPara.isArray)) { //dataset参数 但不是矩阵
        @synchronized(self){
            
            NSMutableArray<NSString *> *arrStr = [offlineVal componentsSeparatedByString:@"|"];
            arrStr[rSubind] = rStrVal;
            NSString *tempHex = arrStr[0];
            for (int i=1; i<2; i++) {
                tempHex = [tempHex stringByAppendingString:[NSString stringWithFormat:@"|%@",arrStr[i]]];
            }
            offlineVal = tempHex;
            //                if ([arrStr[subindex] isEqualToString:@""]) {
            //                    if (subindex == 0) {
            //                        readHex = [NSString stringWithFormat:@"%@%@%@",valH,@"|",arrStr[1]];
            //                    } else if (subindex == 1){
            //                        readHex = [NSString stringWithFormat:@"%@%@%@",arrStr[0],@"|",valH];
            //                    }
            //                } else {
            //                    NSRange tRang = [readHex rangeOfString:arrStr[subindex]];
            //                    readHex = [readHex stringByReplacingOccurrencesOfString:arrStr[subindex] withString:valH options:NSCaseInsensitiveSearch range:tRang];
            //                }
            
        }
    } else if ((_nowPara.isDataSet) && (_nowPara.isArray)) { //dataset参数 也是矩阵
        
        @synchronized(self){
            NSMutableArray<NSString *> *dataSetAndArrayStr = [offlineVal componentsSeparatedByString:@"|"];
            NSMutableArray<NSString *> *arrayStr = [dataSetAndArrayStr[rSubind] componentsSeparatedByString:@","];
            arrayStr[rArrInd] = rStrVal;
            NSString *tempHex = arrayStr[0];
            for (int i=1; i<self.nowPara.arrayCount; i++) {
                tempHex = [tempHex stringByAppendingString:[NSString stringWithFormat:@",%@",arrayStr[i]]];
            }
            dataSetAndArrayStr[rSubind] = tempHex;
            NSString *tempDAndAStr = dataSetAndArrayStr[0];
            for (int i=1; i<2; i++) {
                tempDAndAStr = [tempDAndAStr stringByAppendingString:[NSString stringWithFormat:@"|%@",dataSetAndArrayStr[i]]];
            }
            offlineVal = tempDAndAStr;
        }
        
    } else if ((!_nowPara.isDataSet) && (_nowPara.isArray)){ //单纯的矩阵参数
        
        @synchronized(self){
            
            NSMutableArray<NSString *> *arrStr = [offlineVal componentsSeparatedByString:@","];
            arrStr[rArrInd] = rStrVal;
            NSString *tempHex = arrStr[0];
            for (int i=1; i<_nowPara.arrayCount; i++) {
                tempHex = [tempHex stringByAppendingString:[NSString stringWithFormat:@",%@",arrStr[i]]];
            }
            offlineVal = tempHex;
            
        }
        
        
    }
}

//hex的离线值读取
- (NSString*)offlineHexValWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd{
    return @"";
}
//hex的离线值设定
- (void)setOfflineStrHexWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd withStrVal:(NSString *)rHexVal{
    
}

#pragma mark - 在线值传入至设定值中
- (void)onlineValToSettingVal{
    
    if ((!_nowPara.isArray) && (!_nowPara.isDataSet)) {
        
        [self setOfflineStrValWithSubindex:0 withArrayIndex:0 withStrVal:hexToDisp([_nowPara valHexWithSubindex:0 withArrayIndex:0], _nowPara)];
        
    } else if ((!_nowPara.isArray) && (_nowPara.isDataSet)) {
        for (int i=0; i<2; i++) {
            [self setOfflineStrValWithSubindex:i withArrayIndex:0 withStrVal:hexToDisp([_nowPara valHexWithSubindex:i withArrayIndex:0], _nowPara)];
        }
        
    } else if ((_nowPara.isArray) && (!_nowPara.isDataSet)) {
        for (int i=0; i<_nowPara.arrayCount; i++) {
            [self setOfflineStrValWithSubindex:0 withArrayIndex:i withStrVal:hexToDisp([_nowPara valHexWithSubindex:0 withArrayIndex:i], _nowPara)];
        }
        
    } else if ((_nowPara.isArray) && (_nowPara.isDataSet)) {
        
        for (int i=0; i<2; i++) {
            for (int j=0; j<_nowPara.arrayCount; j++) {
                [self setOfflineStrValWithSubindex:i withArrayIndex:j withStrVal:hexToDisp([_nowPara valHexWithSubindex:i withArrayIndex:j], _nowPara)];
            }

        }
    }

}
#pragma mark - 下载参数值至驱动器中
- (Boolean)downloadSettingVal:(WJCHiCommunicator*)rHicom{
    NSString *writeResult;
    if (_nowPara.isReadonly) {
        return YES;
    } else {

        if ((!_nowPara.isArray) && (!_nowPara.isDataSet)) {
            
            if (_nowPara.isString) {
                
                writeResult = [rHicom writeStringWithIndex:_nowPara.index withSubindex:0 withStringData:dispToHex([self offlineStrValWithSubindex:0 withArrayIndex:0], _nowPara)];

            } else {
                writeResult = [rHicom writeWithIndex:_nowPara.index withSubindex:0 withData:dispToHex([self offlineStrValWithSubindex:0 withArrayIndex:0], _nowPara) withDataLen:_nowPara.len];
            }
            
            
        } else if ((!_nowPara.isArray) && (_nowPara.isDataSet)) {
            for (int i=0; i<2; i++) {
                if (_nowPara.isString) {
                    writeResult = [rHicom writeStringWithIndex:_nowPara.index withSubindex:i withStringData:dispToHex([self offlineStrValWithSubindex:i withArrayIndex:0], _nowPara)];
                } else {
                    writeResult = [rHicom writeWithIndex:_nowPara.index withSubindex:i withData:dispToHex([self offlineStrValWithSubindex:i withArrayIndex:0], _nowPara) withDataLen:_nowPara.len];
                }
            }
            
        } else if ((_nowPara.isArray) && (!_nowPara.isDataSet)) {
            for (int i=0; i<_nowPara.arrayCount; i++) {
                writeResult = [rHicom writeArrayWithIndex:_nowPara.index withSubindex:0 withArrayIndex:i withData:dispToHex([self offlineStrValWithSubindex:0 withArrayIndex:i], _nowPara) withDataLen:_nowPara.len];
                
                if ([writeResult isEqualToString:COMM_SUC]) {
                } else {
                    break;
                }
            }
            
        } else if ((_nowPara.isArray) && (_nowPara.isDataSet)) {
            
            for (int i=0; i<2; i++) {
                for (int j=0; j<_nowPara.arrayCount; j++) {
                    writeResult = [rHicom writeArrayWithIndex:_nowPara.index withSubindex:i withArrayIndex:j withData:dispToHex([self offlineStrValWithSubindex:i withArrayIndex:j], _nowPara) withDataLen:_nowPara.len];
                    
                    if ([writeResult isEqualToString:COMM_SUC]) {
                    } else {
                        break;
                    }
                }
                if ([writeResult isEqualToString:COMM_SUC]) {
                } else {
                    break;
                }
            }
        }
    }
    
    if ([writeResult isEqualToString:COMM_SUC]) {
        return YES;
    } else {
        NSLog(@"%@",writeResult);
        return NO;
    }
}
@end


/**************************************
 Hi worklist类
 **************************************/
@interface WJCHiWorklist()

   
@end


@implementation WJCHiWorklist


- (void)fromString:(NSString*)rStr withHiPara:(WJCParameters*)rPara{
    _name = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"sectorname"];
    _hiPara = rPara;
    NSInteger itemNum = [[WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"count"] intValue];
    _item = [[NSMutableArray alloc] initWithCapacity:itemNum];
    
    for (int i=0; i<itemNum; i++) {
        NSString *tempItemS = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:[NSString stringWithFormat:@"elements%d",i]];
        WJCHiWorklistItem *tempItem = [WJCHiWorklistItem hiWorklistItemWithString:tempItemS withHiPara:rPara];
        if (tempItem == nil) {
            
        }else
            [_item addObject:tempItem];
    }
/*
    self.fullName = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"sectorname"];
    self.abbreviativeName = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"sname"];
    
    int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"count"] intValue];
    _items = [[NSMutableArray alloc] initWithCapacity:num];
    
    _visibleItems = [[NSMutableArray alloc] init];
    
    for (int i=0; i<num; i++) {
        NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"elements%d",i]];
        uint16_t tempIndex = [[WJCHiFileExecutor getTagetStringFrom:tempS cutString:@"index"] intValue];
        if ([_abbreviativeName isEqualToString:@""]) {
            NSString *tempSname = [WJCHiFileExecutor getTagetStringFrom:tempS cutString:@"sdesc"];
            if (![tempSname isEqualToString:@""])
                _abbreviativeName = [tempSname substringWithRange:NSMakeRange(0, 2)];
        }
        WJCGroupItem *tempItem = [WJCGroupItem groupItemWithindex:tempIndex name:[NSString stringWithFormat:@"%@%02d",_abbreviativeName,i]];
        [_items addObject:tempItem];
        if (tempIndex != 0) {
            [_visibleItems addObject:tempItem];
        }
        
    }
  */
}

- (instancetype)initWithString:(NSString*)rStr withHiPara:(WJCParameters*)rPara{
    if (self = [super init]) {
        [self fromString:rStr withHiPara:rPara];
    }
    return self;
}

+ (instancetype)hiWorklistWithStr:(NSString*)rStr withHiPara:(WJCParameters*)rPara{
    return [[WJCHiWorklist alloc] initWithString:rStr withHiPara:rPara];
}

//创建空的worklist
- (instancetype)initWithName:(NSString *) rName withHiPara:(WJCParameters*)rPara{
    if (self = [super init]) {
        _name = rName;
        _hiPara = rPara;
        _item = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - 生成string
- (NSString *)worklistToString{
    NSString *contentString = @"";
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_name withTittleString:@"sectorname"]];
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:@"" withTittleString:@"sname"]];
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_item.count] withTittleString:@"count"]];
    
    for (int i=0; i<_item.count; i++) {
            contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[_item[i] worklistItemToString] withTittleString:[NSString stringWithFormat:@"elements%d",i]]];
    }
    return contentString;
}


#pragma mark - 在线值传入至设定值中
- (void)onlineValsToSettingVals{
    for (int i=0; i<_item.count; i++) {
        [_item[i] onlineValToSettingVal];
    }
}

#pragma mark - 下载参数值至驱动器中
- (Boolean)downloadSettingVals:(WJCHiCommunicator*)rHicom{
    Boolean resultB = YES;
    
    
    WJCOneParameter *eepromPara = [_hiPara getOneParaWithIndex:1062];
    NSString *eepromVal = [rHicom readData:eepromPara.index subindex:0];
    
    if (isErr(eepromVal)) {
        if ([_theDelegate respondsToSelector:@selector(downLoadWorklistResult:failItem:failString:)]){
            [_theDelegate downLoadWorklistResult:NO failItem:nil failString:@"获取EE11参数失败！"];
        }
        return NO;
    }
    
    int writeTimes3 = 0;
    NSString *writeResult3 = [rHicom writeWithIndex:eepromPara.index withSubindex:0 withData:@"0000" withDataLen:eepromPara.len];
    
    while (!((writeTimes3 >2) || ([writeResult3 isEqualToString: COMM_SUC]))) {
        writeResult3 = [rHicom writeWithIndex:eepromPara.index withSubindex:0 withData:@"0000" withDataLen:eepromPara.len];
        writeTimes3 += 1;
    }
    if ([writeResult3 isEqualToString:COMM_SUC]) {

    } else {
        NSLog(@"%@",writeResult3);
        if ([_theDelegate respondsToSelector:@selector(downLoadWorklistResult:failItem:failString:)]){
            [_theDelegate downLoadWorklistResult:NO failItem:nil failString:@"设定EE11参数失败！"];
        }
        return NO;
    }
    
    self.downloadFailStep = WJCWorklistDownloadFailStepNone;
    
    for (int i=0; i<_item.count; i++) {
        if (![_item[i] downloadSettingVal:rHicom]) {
            resultB = NO;
            
//            if ([_theDelegate respondsToSelector:@selector(downLoadWorklistResult:failItem:failString:)]){
//                [_theDelegate downLoadWorklistResult:NO failItem:_item[i] failString:@""];
//            }
            if ([_theDelegate respondsToSelector:@selector(downloadWorklistParaFailItem:failString:)]){
                [_theDelegate downloadWorklistParaFailItem:_item[i] failString:@""];
            }
//            WJCWorklistDownloadFailStepRetry,
//            WJCWorklistDownloadFailStepIgnore,
//            WJCWorklistDownloadFailStepCancel
            while(self.downloadFailStep==WJCWorklistDownloadFailStepNone){
                
            }
            if (self.downloadFailStep == WJCWorklistDownloadFailStepRetry) {
                i--;
            } else if (self.downloadFailStep == WJCWorklistDownloadFailStepIgnore) {
                
            } else if (self.downloadFailStep == WJCWorklistDownloadFailStepCancel) {
                self.downloadFailStep =WJCWorklistDownloadFailStepNone;
                break;
            }
            self.downloadFailStep =WJCWorklistDownloadFailStepNone;
        }
    }
    
//    if (resultB)
    {
        int writeTimes = 0;
        NSString *writeResult = [rHicom writeWithIndex:eepromPara.index withSubindex:0 withData:eepromVal withDataLen:eepromPara.len];
        
        while (!((writeTimes >2) || ([writeResult isEqualToString: COMM_SUC]))) {
            writeResult = [rHicom writeWithIndex:eepromPara.index withSubindex:0 withData:eepromVal withDataLen:eepromPara.len];
            writeTimes += 1;
        }
        
        if ([writeResult isEqualToString:COMM_SUC]) {
            
            int writeTimes2 = 0;
            WJCOneParameter *eepromCmd = [_hiPara getOneParaWithIndex:1051];
            NSString *writeResult2 = [rHicom writeWithIndex:eepromCmd.index withSubindex:0 withData:@"0001" withDataLen:eepromCmd.len];
            
            while (!((writeTimes2 >2) || ([writeResult2 isEqualToString: COMM_SUC]))) {
                writeResult2 = [rHicom writeWithIndex:eepromPara.index withSubindex:0 withData:@"0001" withDataLen:eepromPara.len];
                writeTimes2 += 1;
            }
            if ([writeResult2 isEqualToString:COMM_SUC]) {
                
                [NSThread sleepForTimeInterval:1.0f];
                WJCOneParameter *eepromState = [_hiPara getOneParaWithIndex:1052];
                NSString *eepromStateVal = [rHicom readData:eepromState.index subindex:0];
                CFTimeInterval start = CFAbsoluteTimeGetCurrent();
                CFTimeInterval end = CFAbsoluteTimeGetCurrent();
                
                while (!(![eepromStateVal isEqualToString:@"0001"]) || ((end-start)>10)) {
                    [NSThread sleepForTimeInterval:0.3f];
                    eepromStateVal = [rHicom readData:eepromState.index subindex:0];
                    end = CFAbsoluteTimeGetCurrent();
                }
                
                NSLog(@"data:%@---time:%f",eepromStateVal,end-start);
                if ([_theDelegate respondsToSelector:@selector(downLoadWorklistResult:failItem:failString:)]){
                    [_theDelegate downLoadWorklistResult:YES failItem:nil failString:@""];
                }
                return YES;
            } else {
                NSLog(@"%@",writeResult);
                if ([_theDelegate respondsToSelector:@selector(downLoadWorklistResult:failItem:failString:)]){
                    [_theDelegate downLoadWorklistResult:NO failItem:nil failString:@"设定ee00参数失败！"];
                }
                return NO;
            }
            
        }
//        else {
//            NSLog(@"%@",writeResult);
//            if ([_theDelegate respondsToSelector:@selector(downLoadWorklistResult:failItem:failString:)]){
//                [_theDelegate downLoadWorklistResult:NO failItem:nil failString:@"恢复EE11参数失败！"];
//            }
//            return NO;
//        }
    }

    return resultB;
}

@end



