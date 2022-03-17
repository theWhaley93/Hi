//
//  WJCPerUnitValues.m
//  Hi
//
//  Created by apple on 2018/4/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCPerUnitValues.h"
#import "WJCCommonFunctions.h"



/**驱动器状态类
 */
@interface WJCDriverState()

@end

@implementation WJCDriverState


- (instancetype)initWithParas:(WJCParameters*)rPara{
    
    if (self = [super init]) {
        driverStatus = rPara.paras[100];
        driverError = rPara.paras[97];
        driverWarning = rPara.paras[96];
        softwareEnabled = rPara.paras[17];
        operationKey = rPara.paras[18];
    }
    return self;
    
}

+ (instancetype)driverStateWithParas:(WJCParameters*)rPara{
    
    return [[WJCDriverState alloc] initWithParas:rPara];
    
}

- (void)setDriverStatus:(int)rData{
    _isPulseEnabled = ((rData & (1 >> 0)) == 0) ? NO : YES;
    
    _isError = ((rData & (1 << 1)) == 0) ? NO : YES;
    
    _isRunning = ((rData & (1 << 2)) == 0) ? NO : YES;
    
    _isReverse = ((rData & (1 << 3)) == 0) ? NO : YES;
    
    _isReady = ((rData & (1 << 7)) == 0) ? NO : YES;
    
    _isBusy = ((rData & (1 << 8)) == 0) ? NO : YES;
    
    _isHint = ((rData & (1 << 9)) == 0) ? NO : YES;
    
    _isDataSet = ((rData & (7 << 4)) == 0) ? NO : YES;
}

//更新驱动器参数
- (void)uploadDriverStateWithHiCom:(WJCHiCommunicator *)rHiCom withDescDealer:(WJCDescDealer*)rDescDealer{
    
    if (_toChangeSoftwareEnabled) {
        if ([[softwareEnabled valHexWithSubindex:0 withArrayIndex:0] isEqualToString:@"0000"]) {
            [rHiCom writeWithIndex:softwareEnabled.index withSubindex:0 withData:@"0001" withDataLen:2];
        } else {
            [rHiCom writeWithIndex:softwareEnabled.index withSubindex:0 withData:@"0000" withDataLen:2];
        }
        _toChangeSoftwareEnabled = NO;
    }
    
    if (_toReset) {
        [rHiCom writeWithIndex:operationKey.index withSubindex:0 withData:@"0000" withDataLen:2];
        
        _toReset = NO;
    }
    
    NSString *tempStr = [rHiCom readData:driverStatus.index subindex:0];
    if (isErr(tempStr)) {
        tempStr = [driverStatus strToHex:@"0000"];
    }
    [driverStatus setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];
 
    tempStr = [rHiCom readData:driverError.index subindex:0];
    if (isErr(tempStr)) {
        tempStr = [driverError strToHex:@"0000"];
    }
    [driverError setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];
    
    tempStr = [rHiCom readData:driverWarning.index subindex:0];
    if (isErr(tempStr)) {
        tempStr = [driverWarning strToHex:@"0000"];
    }
    [driverWarning setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];
    
    tempStr = [rHiCom readData:softwareEnabled.index subindex:0];
    if (isErr(tempStr)) {
//        tempStr = [driverWarning strToHex:@"0000"];
    } else
        [softwareEnabled setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];
    
    if ([[softwareEnabled valHexWithSubindex:0 withArrayIndex:0] isEqualToString:@"0000"]) {
        _isSoftwareEnabled = NO;
    } else
        _isSoftwareEnabled = YES;
    
    self.errDescription = [NSString stringWithFormat:@"%@%@%@%@",[driverError valStrWithSubindex:0 withArrayIndex:0],@" (",[rDescDealer descriptionFromValue:[driverError valStrWithSubindex:0 withArrayIndex:0] fromAddr:driverError],@")" ];
    
    self.warningDescription = [NSString stringWithFormat:@"%@%@%@%@",[driverWarning valStrWithSubindex:0 withArrayIndex:0],@" (",[rDescDealer descriptionFromValue:[driverWarning valStrWithSubindex:0 withArrayIndex:0] fromAddr:driverWarning],@")" ];
    
    int tempD = strtoul([[driverStatus valHexWithSubindex:0 withArrayIndex:0] UTF8String], 0, 16);
    [self setDriverStatus:tempD];
}

@end

/**标幺值类
 */
@interface WJCPerUnitValues()

@end

@implementation WJCPerUnitValues

- (double)maxSpeedVal{
    
    NSString *tempStr = [maxSpeed valHexWithSubindex:0 withArrayIndex:0];

    return strtoul([tempStr UTF8String], 0, 16);
}

- (double)maxCurrentVal{
    NSString *tempStr = [maxCurrent valHexWithSubindex:0 withArrayIndex:0];

    return (strtoul([tempStr UTF8String], 0, 16) / 10);
}

- (double)ratedVoltageVal{
    NSString *tempStr = [ratedVoltage valHexWithSubindex:0 withArrayIndex:0];
    
    return strtoul([tempStr UTF8String], 0, 16);
}




- (instancetype)initWithParas:(WJCParameters*)rPara{
    
    if (self = [super init]) {
        maxSpeed = rPara.paras[87];
        ratedVoltage = rPara.paras[88];
        maxCurrent = rPara.paras[89];
    }
    return self;
}

+ (instancetype)perUnitValueWithParas:(WJCParameters*)rPara{
    
    return [[WJCPerUnitValues alloc] initWithParas:rPara];
    
}

- (void)uploadPerUnitValues:(WJCHiCommunicator*)hiCom{
    
    NSString *tempStr = [hiCom readData:maxSpeed.index subindex:0];
    if (isErr(tempStr)) {
        tempStr = [maxSpeed strToHex:@"1000"];
    }
    [maxSpeed setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];
    
    tempStr = [hiCom readData:ratedVoltage.index subindex:0];
    if (isErr(tempStr)) {
        tempStr = [ratedVoltage strToHex:@"540"];
    }
    [ratedVoltage setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];

    tempStr = [hiCom readData:maxCurrent.index subindex:0];
    if (isErr(tempStr)) {
        tempStr = [maxCurrent strToHex:@"20"];
    }
    [maxCurrent setValHexWithSubindex:0 withArrayIndex:0 val:tempStr];
    
    nowPerUnit.maxSpeed = self.maxSpeedVal;
    nowPerUnit.ratedVoltage = self.ratedVoltageVal;
    nowPerUnit.maxCurrent = self.maxCurrentVal;
    
}

@end
