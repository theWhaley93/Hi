//
//  WJCOneParameter.m
//  Hi
//
//  Created by apple on 2018/1/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCOneParameter.h"
#import "WJCCommonFunctions.h"
#import "WJCHiHexDealer.h"
#import "WJCGlobalConstants.h"
#import "WJCDescDealer.h"


/** 参数属性中用到的常量，仅在本文件中用到
 */
typedef union _bytesDealer{
    Byte byte[8];
    Byte uint8;
    uint16_t uint16;
    uint32_t uint32;
    uint64_t uint64;
    int8_t int8;
    int16_t int16;
    int32_t int32;
    int64_t int64;
    float floatV;
    double doulbeV;
    TimeValue64 data;
}bytesDealer;
WJCPerUnitValueStruct nowPerUnit;

double fixEx(double inex, WJCOneParameter * addr){

    double resultF = 0;
    switch (addr.basedType) {
        case TBST_NONE:
            resultF = inex * (addr.vMul) / (addr.vDiv);
            break;
        case TBST_SPEED:
            resultF = inex / (Q30) * (nowPerUnit.maxSpeed) * (addr.vMul) / (addr.vDiv);
            break;
        case TBST_CURRENT:
            resultF = inex / (Q14) * (nowPerUnit.maxCurrent) * (addr.vMul) / (addr.vDiv);
            break;
        case TBST_VOLTAGE:
            resultF = inex / (Q14) * (nowPerUnit.ratedVoltage) * (addr.vMul) / (addr.vDiv);
            break;
        case TBST_OTHER:
            resultF = inex / (Q30) * (addr.vMul) / (addr.vDiv);
            break;
        case TBST_VOLTAGE_S:
            resultF = inex / Q14 / SQR2 * (nowPerUnit.ratedVoltage) * (addr.vMul) / (addr.vDiv);
            break;
        case TBST_Q32:
            resultF = inex / (Q32) * (addr.vMul) / (addr.vDiv);
            break;
    }
    return resultF;
}

double reverseFixEx(double inex, WJCOneParameter * addr){
    
    double resultF = 0;
    switch (addr.basedType) {
        case TBST_NONE:
            resultF = inex / (addr.vMul) * (addr.vDiv);
            break;
        case TBST_SPEED:
            resultF = inex * (Q30) / (nowPerUnit.maxSpeed) / (addr.vMul) * (addr.vDiv);
            break;
        case TBST_CURRENT:
            resultF = inex * (Q14) / (nowPerUnit.maxCurrent) / (addr.vMul) * (addr.vDiv);
            break;
        case TBST_VOLTAGE:
            resultF = inex * (Q14) / (nowPerUnit.ratedVoltage) / (addr.vMul) * (addr.vDiv);
            break;
        case TBST_OTHER:
            resultF = inex * (Q30) / (addr.vMul) * (addr.vDiv);
            break;
        case TBST_VOLTAGE_S:
            resultF = inex * Q14 * SQR2 / (nowPerUnit.ratedVoltage) / (addr.vMul) * (addr.vDiv);
            break;
        case TBST_Q32:
            resultF = inex * (Q32) / (addr.vMul) * (addr.vDiv);
            break;
    }
    return resultF;
}

/**
 参数hex值转成显示值
！！！！！！几个关于时间值的转换还为实现！！！！！！wjcundisposed
 
 @param valStr 输入值，字符串
 @param addr 参数实例
 @return 返回显示值
 */

NSString * hexToDisp(NSString * valStr, WJCOneParameter * addr){    //hex转成显示值
    
    NSString *resultStr = valStr;
    
    if (notErr(valStr)) {
        bytesDealer tempDealer;
        for (int i=0; i<8; i++) {
            tempDealer.byte[i] = 0;
        }
        if (valStr.length < (addr.len *2)) {
            resultStr = @"";
        }
        else{
        
            switch (addr.typ) {
                case DT_VOID:
                    break;
                case DT_BOOL:{
                    NSRange tempRange = NSMakeRange(1, 1);
                    if ([[valStr substringWithRange:tempRange] isEqualToString:@"0"]) {
                        resultStr = @"YES";
                    } else {
                        resultStr = @"NO";
                    }
                    break;
                }
                case DT_SINT:{
                    NSRange tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    double ex = tempDealer.int8;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_INT:{
                    NSRange tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    double ex = tempDealer.int16;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_DINT:{
                    
                    NSRange tempRange = NSMakeRange(6, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(4, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[2] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[3] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.int32;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_LINT:{
                    NSRange tempRange = NSMakeRange(14, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(12, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(10, 2);
                    tempDealer.byte[2] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(8, 2);
                    tempDealer.byte[3] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(6, 2);
                    tempDealer.byte[4] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(4, 2);
                    tempDealer.byte[5] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[6] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[7] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.int64;
                    
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_USINT:{
                    
                    NSRange tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.uint8;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_UINT:{
                    
                    NSRange tempRange = NSMakeRange(2, 2);
                    if ((valStr.length <4)) {
                        int i = 1;
                    }
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.uint16;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_UDINT:{

                    NSRange tempRange = NSMakeRange(6, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(4, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[2] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[3] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.uint32;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_ULINT:{
                    NSRange tempRange = NSMakeRange(14, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(12, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(10, 2);
                    tempDealer.byte[2] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(8, 2);
                    tempDealer.byte[3] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(6, 2);
                    tempDealer.byte[4] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(4, 2);
                    tempDealer.byte[5] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[6] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[7] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.uint64;
                    
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_REAL:{
                    NSRange tempRange = NSMakeRange(6, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(4, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[2] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[3] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.floatV;
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_LREAL:{
                    NSRange tempRange = NSMakeRange(14, 2);
                    tempDealer.byte[0] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(12, 2);
                    tempDealer.byte[1] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(10, 2);
                    tempDealer.byte[2] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(8, 2);
                    tempDealer.byte[3] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(6, 2);
                    tempDealer.byte[4] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(4, 2);
                    tempDealer.byte[5] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(2, 2);
                    tempDealer.byte[6] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    tempRange = NSMakeRange(0, 2);
                    tempDealer.byte[7] = strtoul([[valStr substringWithRange:tempRange] UTF8String],0,16);
                    
                    double ex = tempDealer.doulbeV;
                    
                    resultStr = [WJCHiHexDealer fixZero:[NSString stringWithFormat:@"%f",fixEx(ex, addr)] radixPos:addr.radixPointPos fix5:YES];
                    break;
                }
                case DT_TIME:{
                    
                    break;
                }
                case DT_DATE:
    //时间转换
                    break;
                case DT_TIME_OF_DAY:
    //时间转换
                    break;
                case DT_DATE_AND_TIME:
    //时间转换
                    break;
                case DT_STRING:
                    resultStr = valStr;
                    break;
                case DT_BYTE:
                    resultStr = valStr;
                    break;
                case DT_WORD:
                    resultStr = valStr;
                    break;
                case DT_DWORD:
                    resultStr = valStr;
                    break;
                case DT_LWORD:
                    resultStr = valStr;
                    break;
                case DT_ERRCODE:
                    resultStr = valStr;
                    break;
            }
    }
        if (addr.radixPointPos > 0) {
            resultStr = [WJCHiHexDealer fixZero:resultStr radixPos:addr.radixPointPos fix5:YES];
        }
    }

    return resultStr;
}


NSString * dispToHex(NSString *s, WJCOneParameter *addr){
    NSString *resultS = @"";
    double ex;
//    DT_VOID,  DT_BOOL, DT_SINT,  DT_INT,   DT_DINT,  DT_LINT,
//    DT_USINT, DT_UINT, DT_UDINT, DT_ULINT, DT_REAL,  DT_LREAL,
//    DT_TIME,  DT_DATE, DT_TIME_OF_DAY, DT_DATE_AND_TIME,  DT_STRING, DT_BYTE, DY_WORD,
//    DT_DWORD, DT_LWORD, DT_ERRCODE

    switch (addr.typ) {
        case DT_VOID:{
            resultS = @"";
            break;
        }
        case DT_BOOL:{
            
            if ([s isEqualToString:@"YES"]) {
                resultS = @"01";
            } else {
                resultS = @"00";
            }
            
            break;
        }
        case DT_SINT: case DT_INT: case DT_DINT:case DT_LINT: case DT_USINT: case DT_UINT: case DT_UDINT:case  DT_ULINT:{
            ex = reverseFixEx([s floatValue],addr);
            
            int hexValue = round(ex);
            
            for (int i=0; i<addr.len; i++) {
                Byte tempB = (hexValue >> (i*8)) & 0xFF;
                resultS = [NSString stringWithFormat:@"%02X%@",tempB,resultS];
            }
            
            break;
        }
        case DT_REAL:{
            ex = reverseFixEx([s floatValue],addr);
            float temF = ex;
            for (int i=0; i<4; i++) {
                Byte temB = *((Byte *)(&temF) + i);
                resultS = [NSString stringWithFormat:@"%02X%@",temB,resultS];
            }

            break;
        }
        case DT_LREAL:{
            ex = reverseFixEx([s floatValue],addr);
            for (int i=0; i<8; i++) {
                Byte temB = *((Byte *)(&ex) + i);
                resultS = [NSString stringWithFormat:@"%02X%@",temB,resultS];
            }
            break;
        }
        case DT_DATE:{//wjc20180329时间
            resultS = @"";
            break;
        }
        case DT_TIME: case DT_TIME_OF_DAY:{
            resultS = @"";
            break;
        }
        case DT_DATE_AND_TIME:{
            resultS = @"";
            break;
        }
        case DT_STRING:{
            resultS = s;
            break;
        }
        case DT_BYTE: case DT_WORD:case DT_DWORD:case DT_LWORD: case DT_ERRCODE:{
            NSInteger tempValD = strtol([s UTF8String], 0, 16);
            switch (addr.len) {
                case 1:
                    resultS = [NSString stringWithFormat:@"%02X",tempValD];
                    break;
                case 2:
                    resultS = [NSString stringWithFormat:@"%04X",tempValD];
                    break;
                case 4:
                    resultS = [NSString stringWithFormat:@"%08X",tempValD];
                    break;
                case 8:
                    resultS = [NSString stringWithFormat:@"%016X",tempValD];
                    break;
            }
            break;
        }
    }
    return resultS;
}


@interface WJCOneParameter()

@end


@implementation WJCOneParameter



//hex值的交换
- (NSString *)valHexWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd{
    
    NSString *temps = @"";
    if ((! self.isArray) && (! self.isDataSet)) {
        //互斥锁
        @synchronized(self){
            temps = readHex;
        }
        
    } else if ((self.isDataSet) && (!self.isArray)){
        @synchronized(self){
            NSArray *arrStr = [readHex componentsSeparatedByString:@"|"];
            temps = arrStr[subindex];
        }
    } else if ((self.isDataSet) && (self.isArray)){
        @synchronized(self){
            NSArray *dataSetAndArrayStr= [readHex componentsSeparatedByString:@"|"];
            NSArray *arrayStr = [dataSetAndArrayStr[subindex] componentsSeparatedByString:@","];
            temps = arrayStr[arrayInd];
        }
    } else if ((!self.isDataSet) && (self.isArray)) {
        @synchronized(self){
            NSArray *arrStr = [readHex componentsSeparatedByString:@","];
            temps = arrStr[arrayInd];
        }
    }
    
    return temps;
}

- (void)setValHexWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd val:(NSString *) valH{
    
    if (notErr(valH)) {
        
        if ((! self.isArray) && (! self.isDataSet)) { //普通参数
            //互斥锁
            @synchronized(self){
                readHex = valH;
            }
            
        } else if ((self.isDataSet) && (!self.isArray)) { //dataset参数 但不是矩阵
            @synchronized(self){
            
                NSMutableArray<NSString *> *arrStr = [readHex componentsSeparatedByString:@"|"];
                arrStr[subindex] = valH;
                NSString *tempHex = arrStr[0];
                for (int i=1; i<2; i++) {
                    tempHex = [tempHex stringByAppendingString:[NSString stringWithFormat:@"|%@",arrStr[i]]];
                }
                readHex = tempHex;
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
        } else if ((self.isDataSet) && (self.isArray)) { //dataset参数 也是矩阵
            
            @synchronized(self){
                NSMutableArray<NSString *> *dataSetAndArrayStr = [readHex componentsSeparatedByString:@"|"];
                NSMutableArray<NSString *> *arrayStr = [dataSetAndArrayStr[subindex] componentsSeparatedByString:@","];
                arrayStr[arrayInd] = valH;
                NSString *tempHex = arrayStr[0];
                for (int i=1; i<self.arrayCount; i++) {
                    tempHex = [tempHex stringByAppendingString:[NSString stringWithFormat:@",%@",arrayStr[i]]];
                }
                dataSetAndArrayStr[subindex] = tempHex;
                NSString *tempDAndAStr = dataSetAndArrayStr[0];
                for (int i=1; i<2; i++) {
                    tempDAndAStr = [tempDAndAStr stringByAppendingString:[NSString stringWithFormat:@"|%@",dataSetAndArrayStr[i]]];
                }
                readHex = tempDAndAStr;
            }
            
        } else if ((!self.isDataSet) && (self.isArray)){ //单纯的矩阵参数
            
            @synchronized(self){
                
                NSMutableArray<NSString *> *arrStr = [readHex componentsSeparatedByString:@","];
                arrStr[arrayInd] = valH;
                NSString *tempHex = arrStr[0];
                for (int i=1; i<self.arrayCount; i++) {
                    tempHex = [tempHex stringByAppendingString:[NSString stringWithFormat:@",%@",arrStr[i]]];
                }
                readHex = tempHex;
                
            }


        }
            
    }

}

//string值的交换
- (NSString *)valStrWithSubindex:(uint32_t)subindex withArrayIndex:(uint32_t)arrayInd{
    
    
    return hexToDisp([self valHexWithSubindex:subindex withArrayIndex:arrayInd], self);
}

- (void)setValStrWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd val:(NSString *) valS{
    [self setValHexWithSubindex:subindex withArrayIndex:arrayInd val:[self strToHex:valS]];
}

#pragma mark-初始化类
/**
 解析、生成字符串
 */
- (Boolean)fromString:(NSString *) str{
    
    actData = WJCMakeAddrStruct([WJCHiFileExecutor getTagetStringFrom:str cutString:@"attr"]);
    self.index = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"index"] intValue];
    groupIndex = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"gindex"] intValue];
    groupSubindex = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"gsubindex"] intValue];
    self.sDescribe = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"sdesc"] ;
    self.lDescribe = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"ldesc"] ;
    self.offlineVal = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"offlineval"] ;
    arrayWidth = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"ArrayWidth"] intValue];
    arrayLength = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"ArrayLength"] intValue];
    
    NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"max"];
    for (int i=0; i<8; i++) {
        NSRange range = NSMakeRange(i*2, 2);
        max[i] =  strtoul([[tempS substringWithRange:range] UTF8String],0,16);
    }
    
    tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"min"];
    for (int i=0; i<8; i++) {
        NSRange range = NSMakeRange(i*2, 2);
        min[i] =  strtoul([[tempS substringWithRange:range] UTF8String],0,16);
    }

    tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"defaultVal"];
    for (int i=0; i<8; i++) {
        NSRange range = NSMakeRange(i*2, 2);
        defaultVal[i] =  strtoul([[tempS substringWithRange:range] UTF8String],0,16);
    }
    [self initReadHex];
    [self initDefaultNewStr];
    
    return YES;
}
/**
 生成字符串
 */
- (NSString *)toString{
    NSString *contentStr = @"";
    
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:WJCMakeAddrStructToString(actData) withTittleString:@"attr"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",_index] withTittleString:@"index"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",groupIndex] withTittleString:@"gindex"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",groupSubindex] withTittleString:@"gsubindex"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_sDescribe withTittleString:@"sdesc"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_lDescribe withTittleString:@"ldesc"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_offlineVal withTittleString:@"offlineval"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",arrayWidth] withTittleString:@"ArrayWidth"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",arrayLength]  withTittleString:@"ArrayLength"]];

    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:self.maxHexString withTittleString:@"max"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:self.minHexString withTittleString:@"min"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:self.defHexString withTittleString:@"defaultVal"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:@"" withTittleString:@"readhex"]];
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:self.usedReadHex withTittleString:@"readhex00"]];
//    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:self->offlineVal withTittleString:@"offlineval00"]];
    return contentStr;
}
/**
 初始化类
 */
- (instancetype)initWithString:(NSString *) str{
    if (self = [super init]) {
        [self fromString:str];
    }
    return self;
}

+ (instancetype)oneParameterWithString:(NSString *) str{
    return [[WJCOneParameter alloc] initWithString:str];
}

#pragma mark-所有属性的读取
- (NSString *)usedReadHex{
    return readHex;
}

/* 标幺类型属性
 */

- (uint32_t)arrayCount{     //矩阵长度
    if (self.isArray) {
        return (arrayLength*arrayWidth);
    } else
        return 0;
    
}

- (WJCBasedType)basedType{    //标幺类型
    UInt8 tempa = ((actData.attribute) >> 12) & 0x07;
    return (WJCBasedType)tempa;
}

- (NSString *)basedTypeString{   //标幺的文字描述
    NSString *resultStr = @"";
    switch (self.basedType) {
        case TBST_NONE:
            resultStr = @"通常";
            break;
        case TBST_SPEED:
            resultStr = @"转速";
            break;
        case TBST_CURRENT:
            resultStr = @"电流";
            break;
        case TBST_VOLTAGE:
            resultStr = @"电压";
            break;
        case TBST_OTHER:
            resultStr = @"其他";
            break;
        case TBST_VOLTAGE_S:
            resultStr = @"电压";
            break;
        case TBST_Q32:
            resultStr = @"其他2";
            break;
    }
    return resultStr;
}

- (NSString *)realSymbol{   //标幺符号
    NSString *resultStr = @"";
    switch (self.basedType) {
        case TBST_NONE:
            resultStr = self.symbol;
            break;
        case TBST_SPEED:
            resultStr = @"r/min";
            break;
        case TBST_CURRENT:
            resultStr = @"A";
            break;
        case TBST_VOLTAGE:
            resultStr = @"V";
            break;
        case TBST_OTHER:
            resultStr = self.symbol;
            break;
        default:
            break;
//        case TBST_VOLTAGE_S:
//            resultStr = @"电压";
//            break;
//        case TBST_Q32:
//            resultStr = @"其他2";
//            break;
    }
    return resultStr;
}

/* 值类型
 */
- (NSArray *)dsDataType{
    NSArray *staticType = @[@"DT_VOID",@"DT_BOOL",@"DT_SINT",@"DT_INT",@"DT_DINT",@"DT_LINT",@"DT_USINT",@"DT_UINT",@"DT_UDINT",@"DT_ULINT",@"DT_REAL",@"DT_LREAL",@"DT_TIME",@"DT_DATE",@"DT_TIME_OF_DAY",@"DT_DATE_AND_TIME",@"DT_STRING",@"DT_BYTE",@"DT_WORD",@"DT_DWORD",@"DT_LWORD",@"DT_ERRCODE"];
    return staticType;
}
- (WJCDataType)typ{     //类型
    return actData.dataType;
}

- (uint32_t)len{        //参数长度
    uint32_t l = 2;
    switch (actData.dataType) {
        case DT_VOID:
            l = 4;
            break;
        case DT_BOOL:
            l = 1;
            break;
        case DT_SINT:
            l = 1;
            break;
        case DT_INT:
            l = 2;
            break;
        case DT_DINT:
            l = 4;
            break;
        case DT_LINT:
            l = 8;
            break;
        case DT_USINT:
            l = 1;
            break;
        case DT_UINT:
            l = 2;
            break;
        case DT_UDINT:
            l = 4;
            break;
        case DT_ULINT:
            l = 8;
            break;
        case DT_REAL:
            l = 4;
            break;
        case DT_LREAL:
            l = 8;
            break;
        case DT_TIME:
            l = 4;
            break;
        case DT_DATE:
            l = 4;
            break;
        case DT_TIME_OF_DAY:
            l = 4;
            break;
        case DT_DATE_AND_TIME:
            l = 4;
            break;
        case DT_STRING:
            l = 2;
            break;
        case DT_BYTE:
            l = 1;
            break;
        case DT_WORD:
            l = 2;
            break;
        case DT_DWORD:
            l = 4;
            break;
        case DT_LWORD:
            l = 8;
            break;
        case DT_ERRCODE:
            l = 2;
            break;
    }
    return l;
}

- (NSString *)typeString{       //类型的额文字描述
    return self.dsDataType[(int)(actData.dataType)];
}

- (NSString *)attributeString{      //属性的文字描述
    return [NSString stringWithFormat:@"%08X",actData.attribute];
}

- (Boolean)sign{        //正负符号
    Boolean b = NO;
    switch (actData.dataType) {
        case DT_VOID:
            b = NO;
            break;
        case DT_BOOL:
            b = NO;
            break;
        case DT_SINT:
            b = YES;
            break;
        case DT_INT:
            b = YES;
            break;
        case DT_DINT:
            b = YES;
            break;
        case DT_LINT:
            b = YES;
            break;
        case DT_USINT:
            b = NO;
            break;
        case DT_UINT:
            b = NO;
            break;
        case DT_UDINT:
            b = NO;
            break;
        case DT_ULINT:
            b = NO;
            break;
        case DT_REAL:
            b = YES;
            break;
        case DT_LREAL:
            b = YES;
            break;
        case DT_TIME:
            b = NO;
            break;
        case DT_DATE:
            b = NO;
            break;
        case DT_TIME_OF_DAY:
            b = NO;
            break;
        case DT_DATE_AND_TIME:
            b = NO;
            break;
        case DT_STRING:
            b = NO;
            break;
        case DT_BYTE:
            b = NO;
            break;
        case DT_WORD:
            b = NO;
            break;
        case DT_DWORD:
            b = NO;
            break;
        case DT_LWORD:
            b = NO;
            break;
        case DT_ERRCODE:
            b = NO;
            break;
    }
    return b;
}

- (Boolean)isDate{      //是否日期
    Boolean b = NO;
    switch (actData.dataType) {
        case DT_TIME:
            b = YES;
            break;
        case DT_DATE:
            b = YES;
            break;
        case DT_TIME_OF_DAY:
            b = YES;
            break;
        case DT_DATE_AND_TIME:
            b = YES;
            break;
        default:
            b = NO;
            break;
    }
    return b;
}

- (uint32_t)radixPointPos{      //小数点位数0,1,2,3
    return ((actData.attribute >> 7) & 3);
}

- (NSString *)symbol{
    NSString *s = @"";
    switch ((actData.attribute >> 16) & 31) {
        case 0:
            s = @"";
            break;
        case 1:
            s = @"Hz";
            break;
        case 2:
            s = @"s";
            break;
        case 3:
            s = @"%";
            break;
        case 4:
            s = @"A";
            break;
        case 5:
            s = @"V";
            break;
        case 6:
            s = @"r/min";
            break;
        case 7:
            s = @"°C";
            break;
        case 8:
            s = @"ms";
            break;
        case 9:
            s = @"µs";
            break;
        case 10:
            s = @"KHz";
            break;
        case 11:
            s = @"°";
            break;
        case 12:
            s = @"Ω";
            break;
        case 13:
            s = @"mH";
            break;
        case 14:
            s = @"N*m";
            break;
        case 15:
            s = @"kg*m^2*10^-3";
            break;
        case 16:
            s = @"W";
            break;
        case 17:
            s = @"KW";
            break;
        case 18:
            s = @"Hex";
            break;
        case 19:
            s = @"kg";
            break;
        case 20:
            s = @"Mpa";
            break;
        case 21:
            s = @"bar";
            break;
        case 22:
            s = @"kg/cm^2";
            break;
        case 23:
            s = @"minute";
            break;
        case 24:
            s = @"hour";
            break;
        case 25:
            s = @"V/A";
            break;
        case 26:
            s = @"inc/ms";
            break;
    }
    return s;
}

- (Boolean)isReadonly{      //是否只读
    return ((actData.attribute & 3) == 0);
}

- (Boolean)isArray{
    return (((actData.attribute >> 6) & 1) == 1);
}

- (Boolean)isDataSet{
    return (((actData.attribute >> 2) & 1) == 1);
}

- (Boolean)isRetain{    //是否保存
    return (((actData.attribute >> 3) & 1) == 1);
}

- (uint32_t)access{     //权限类型
    return (actData.attribute & 3);
}

- (uint32_t)descType{       //描述类型
    return ((actData.attribute >> 21) & 3);
}

- (WJCDateDescType)descTypeEnum{    //描述类型，返回枚举
    WJCDateDescType resultType = DDT_NONE;
    
    switch (self.descType) {
        case 0:{
            if (self.isHex) {
                resultType = DDT_NONE_BIT;
            } else {
                resultType = DDT_NONE;
            }
            break;
        }
        case 1:{
            resultType = DDT_DESC_NORMAL;
            break;
        }
        case 2:{
            resultType = DDT_DESC_BIT;
            break;
        }
        case 3:{
            resultType = DDT_DESC_BITS;
            break;
        }
        default:
            break;
    }
    return resultType;
}

- (uint32_t)level{
    return ((actData.attribute >> 9) & 3);
}

- (uint32_t)vMul{       //乘数
    return actData.vMul;
}

- (uint32_t)vDiv{       //除数
    return actData.vDiv;
}

- (NSString *)describe{
    return [NSString stringWithFormat:@"%@  %@",self.sDescribe,self.lDescribe];
}

- (NSString *)wDescribe{
    return [NSString stringWithFormat:@"%@:%@",self.sDescribe,self.lDescribe];
}

- (NSString *)setDisp{
    if ([self.offlineVal isEqualToString:@""]) {
        if (notErr(self.offlineVal)) {
            return self.offlineVal;
        }
    }
    return @"0";
}


- (uint32_t)intVal{
    //没用到该属性
    return 0;
}

- (double)defVal{
    NSString * temS = @"";
    for (int i=self.len-1; i>=0; i--) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",defaultVal[i]]];
    }
    return [hexToDisp(temS, self) floatValue];
}


- (NSString *)defStr{
    return hexToDisp(self.defHex, self);
}

- (NSString *)defHex{
    NSString * temS = @"";
    for (int i=self.len-1; i>=0; i--) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",defaultVal[i]]];
    }
    return temS;
}
- (NSString *)defHexString{
    NSString * temS = @"";
    for (int i=0; i<8; i++) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",defaultVal[i]]];
    }
    return temS;
}

- (double)minVal{
    if (self.isHex) {
        return 0;
    }
    NSString * tempS = @"";
    if (self.isDate) { //wjcundisposed 时间类型未处理
        tempS  = @"";
    } else {
        tempS = hexToDisp(self.minHex, self);
    }
    return [tempS floatValue];
}

- (void)setMinVal:(double)minVal{   //wjcundisposed 时间类型未处理
    
}


- (NSString *)minStr{
    return hexToDisp(self.minHex, self);
}

- (NSString *)minHex{
    NSString * temS = @"";
    for (int i=self.len-1; i>=0; i--) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",min[i]]];
    }
    return temS;
}

- (NSString *)minHexString{
    NSString * temS = @"";
    for (int i=0; i<8; i++) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",min[i]]];
    }
    return temS;
}

- (double)maxVal{
    if (self.isHex) {
        return 0;
    }
    if (self.isDate) {
        //wjcundisposed 时间类型未处理
        return 0;
    } else {
        NSString * tempS = @"";
        if (actData.dataType == DT_STRING) {
            return 255;
        } else {
            tempS = hexToDisp(self.maxHex, self);
            return [tempS floatValue];
        }
    }
        
}

- (void)setMaxVal:(double)maxVal{
    //wjcundisposed 时间类型未处理
}


- (NSString *)maxStr{
    return hexToDisp(self.maxHex, self);
}

- (NSString *)maxHex{
    NSString * temS = @"";
    for (int i=self.len-1; i>=0; i--) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",max[i]]];
    }
    return temS;
}

- (NSString *)maxHexString{
    NSString * temS = @"";
    for (int i=0; i<8; i++) {
        temS = [temS stringByAppendingString:[NSString stringWithFormat:@"%02X",max[i]]];
    }
    return temS;
}

- (Boolean)isHex{
    switch (actData.dataType) {
        case DT_BYTE:case DT_WORD:case DT_DWORD:case DT_LWORD:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (Boolean)isString{
    switch (actData.dataType) {
        case DT_STRING:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (Boolean)isFloat{
    switch (actData.dataType) {
        case DT_REAL:case DT_LREAL:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (NSString *)indexStr{
    return [NSString stringWithFormat:@"%d",self.index];
}


#pragma mark- 其他函数方法

- (NSString *)strToHex:(NSString *)s{
    return dispToHex(s, self);
}

- (NSString *)hexToStr:(NSString *)s{
    if ([s isEqualToString:@""]) {
        return @"";
    } else {
        return hexToDisp(s, self);
    }
}


- (NSString *)fixHexLen:(NSString *)s{
    NSString * tempS = @"";
    NSInteger l = [s length];
    if (l > (self.len*2)) {
        NSRange tempR = NSMakeRange(l-self.len*2, self.len*2);
        tempS = [s substringWithRange:tempR];
    } else {
        for (int i=0; i<(self.len*2-l); i++) {
            tempS = [tempS stringByAppendingString:@"0"];
        }
        tempS = [tempS stringByAppendingString:s];
    }
    return tempS;
}

- (void)initReadHex{
    readHex = @"";
    
    if (self.isDataSet) {
        readHex = @"|";
    }
    
    if (self.isArray) {
        NSString *tempArrStr = @"";
        for (int i=0; i<self.arrayCount-1; i++) {
            tempArrStr = [tempArrStr stringByAppendingString:@","];
        }
        
        if (self.isDataSet) {
            readHex = [[tempArrStr stringByAppendingString:readHex] stringByAppendingString:tempArrStr];
        } else {
            readHex = tempArrStr;
        }
    }
    
}

- (void)initDefaultNewStr{
    if (self.isDataSet) {
        if (self.isArray) {
            NSString *tempS = self.defStr;
            for (int i=0; i<self.arrayCount-1; i++) {
                tempS = [tempS stringByAppendingString:[NSString stringWithFormat:@"%@%@",@",",self.defStr]];
            }
            _defStrNew = [NSString stringWithFormat:@"%@|%@",tempS,tempS];
        } else {
            _defStrNew = [NSString stringWithFormat:@"%@|%@",self.defStr,self.defStr];
        }
    } else {
        
        if (self.isArray) {
            _defStrNew = self.defStr;
            for (int i=0; i<self.arrayCount-1; i++) {
                _defStrNew = [_defStrNew stringByAppendingString:[NSString stringWithFormat:@"%@%@",@",",self.defStr]];
            }
        } else {
            _defStrNew = [NSString stringWithFormat:@"%@",self.defStr];
        }
    }
}

- (NSString *)showParaWithoutDesc:(NSString *)val descD:(NSObject *)descr{
    NSString * s1 = @"";
    NSString * s2 = @"";
    if (isErr(val)) {
        s1 = @"No Value";
    } else {
        s2 = hexToDisp(val, self);
        switch (_showType) {
            case SHOWTYPE_DEC:
                s1 = s2;
                break;
            case SHOWTYPE_HEX:
                s1 = val;
                break;
                
        }
    }
    return s1;
}

- (NSString *)showParaDesc:(NSString *)val descD:(NSObject *)descr{
    NSString * s1 = @"";
    NSString * s2 = @"";
    if (isErr(val)) {
        s1 = @"No Value";
    } else {
        s2 = hexToDisp(val, self);
        switch (_showType) {
            case SHOWTYPE_DEC:
                s1 = s2;
                break;
            case SHOWTYPE_HEX:
                s1 = val;
                break;

        }
    }
    NSString *s = [s1 stringByAppendingString:[NSString stringWithFormat:@" %@",self.symbol]];
    if (self.isString) {
        if (isErr(val)) {
            s = @"No Value";
        }
        else
            s = val;
    } else {
        if (notErr(s1)) {
            if (self.descType != 0) {
                NSString *s3 = [((WJCDescDealer *)(descr)) descriptionFromValue:s2 fromAddr:self];
                if ([s3 isEqualToString:@""]) {
                    s3 = @"No Value";
                }
                
                s = [s stringByAppendingString:[NSString stringWithFormat:@"(%@)",s3]];
            }
        }
    }
    return s;
    
}

@end
