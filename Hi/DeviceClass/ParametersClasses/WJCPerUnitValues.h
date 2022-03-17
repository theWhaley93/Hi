//
//  WJCPerUnitValues.h
//  Hi
//
//  Created by apple on 2018/4/7.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCOneParameter.h"
#import "WJCParameters.h"
#import "WJCHiCommunicator.h"
#import "WJCDescDealer.h"


/**驱动器状态类
 */
@interface WJCDriverState : NSObject{
    @public
    WJCOneParameter *driverStatus;  //驱动器状态
    WJCOneParameter *driverError;  //驱动器错误
    WJCOneParameter *driverWarning;  //驱动器警告
    WJCOneParameter *softwareEnabled;   //驱动器软使能
    WJCOneParameter *operationKey;  //驱动器复位按钮DE12
}

@property (nonatomic)   Boolean toChangeSoftwareEnabled;    //切换软使能
@property (nonatomic)   Boolean toReset;    //清除错误

@property (nonatomic,readonly)   Boolean isSoftwareEnabled;    //软使能

@property (nonatomic,readonly)   Boolean isPulseEnabled;    //硬使能
@property (nonatomic,readonly)   Boolean isError;    //是否有错
@property (nonatomic,readonly)   Boolean isRunning;    //
@property (nonatomic,readonly)   Boolean isReverse;    //
@property (nonatomic,readonly)   Boolean isReady;    //
@property (nonatomic,readonly)   Boolean isBusy;    //
@property (nonatomic,readonly)   Boolean isHint;    //是否有警告
@property (nonatomic,readonly)   Boolean isDataSet;    //是否有警告


@property (nonatomic,copy)  NSString *errDescription;  //错误代码
@property (nonatomic,copy)  NSString *warningDescription;  //警告代码


//@property (nonatomic,strong)  WJCOneParameter *driverStatus;  //驱动器状态
//@property (nonatomic,strong)  WJCOneParameter *driverError;  //驱动器错误
//@property (nonatomic,strong)  WJCOneParameter *driverWarning;  //驱动器警告

- (instancetype)initWithParas:(WJCParameters*)rPara;
+ (instancetype)driverStateWithParas:(WJCParameters*)rPara;

- (void)uploadDriverStateWithHiCom:(WJCHiCommunicator *)rHiCom withDescDealer:(WJCDescDealer*)rDescDealer;

- (void)setDriverStatus:(int)rData;

@end




//typedef struct _PerUnitValue{
//    double maxSpeed;
//    double ratedVoltage;
//    double maxCurrent;
//}WJCPerUnitValue;
//
//extern WJCPerUnitValue nowPerUnit;


/**标幺值的类
 */
@interface WJCPerUnitValues : NSObject{
    @public
    WJCOneParameter *maxSpeed;  //最大转速
    WJCOneParameter *ratedVoltage;  //
    WJCOneParameter *maxCurrent;  //
}

//@property (nonatomic,strong)  WJCOneParameter *maxSpeed;  //最大转速
//@property (nonatomic,strong)  WJCOneParameter *ratedVoltage;  //
//@property (nonatomic,strong)  WJCOneParameter *maxCurrent;  //

@property (nonatomic)  double maxSpeedVal;  //最大转速
@property (nonatomic)  double ratedVoltageVal;  //
@property (nonatomic)  double maxCurrentVal;  //

- (instancetype)initWithParas:(WJCParameters*)rPara;
+ (instancetype)perUnitValueWithParas:(WJCParameters*)rPara;


- (void)uploadPerUnitValues:(WJCHiCommunicator*)hiCom;


@end
