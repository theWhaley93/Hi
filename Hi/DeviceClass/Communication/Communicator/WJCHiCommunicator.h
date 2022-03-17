//
//  WJCHiCommunicator.h
//  udp
//
//  Created by apple on 2018/2/12.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCBaseDataConversion.h"
#import "GCDAsyncSocket.h"
#import "WJCOneParameter.h"
#import "WJCDescBitFieldTabs.h"
/** 通讯返回类型
 */
typedef enum {
    NONE, COMMRTN_SUC, COMMRTN_INVBUSY, COMMRTN_OTHERFAIL,
    COMMRTN_TIMEOUT, COMMRTN_CHKERR
} CommReturnState;


/** 通讯类
 */
@interface WJCHiCommunicator : NSObject

/** 属性
 */
@property (nonatomic,strong)  GCDAsyncSocket *clientSocket; //TCP Client


/**创建和连接socket
 */
- (BOOL)createAndConnectSocketOnIP:(NSString *)IP OnPort:(uint16_t)port;
- (BOOL)reconnectSocket;


- (NSString *)readWithPara:(WJCOneParameter *)onePara isArrayEnable:(Boolean) rIsArrEnable;
//读根据index subindex arrayindex读参数
- (NSString *)readWithPara:(WJCOneParameter *)onePara withindex:(int)rIndex withSubindex:(int)rSubI withArrayIndex:(int)rArrayI;
//读根据index subindex arrayindex写参数
- (NSString *)writeWithPara:(WJCOneParameter *)onePara withindex:(int)rIndex withSubindex:(int)rSubI withArrayIndex:(int)rArrayI withValue:(NSString *)rVal;

/**************************************
 Hi通讯协议的所有方法
 **************************************/

/**
 1.读参数协议
 */
- (NSString *)readData:(NSInteger)index subindex:(NSInteger)subi; //普通读参数

- (NSString *)readStringData:(NSInteger)rIndex subindex:(NSInteger)rSubi; //读字符串

- (NSString *)readArrayDataWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withArrayIndex:(NSInteger)rArrayI;

/**
 2.写参数协议
 */
- (NSString *)writeWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withData:(NSString *)rData withDataLen:(int)rDataLen;  //普通写参数

- (NSString *)writeStringWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withStringData:(NSString *)rStringData;  //普通写参数

- (NSString *)writeArrayWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withArrayIndex:(NSInteger)rArrayI withData:(NSString *)rData withDataLen:(int)rDataLen;

- (void)writeDirWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withData:(NSString *)rData withDataLen:(int)rDataLen;  //直接写，无返回

/**
3.读组信息+读描述，更新参数文件时用
 */

/*
 3.1.读描述信息
 */
//读参数索引与描述索引对应的关系
- (NSString *)readDescIndexWithDescNumber:(uint16_t)rSerialNum withSubindex:(Byte)rSubind paraIndex:(int *)rPParaInd descIndex:(int *)rPDescInd;

//读某个参数描述的个数
- (NSString *)readDescCountWithDescIndex:(uint16_t)rDescIndex descCount:(int *)rDescCnt;

//读单条描述
- (NSString *)readOneDescWithDescTabIndex:(uint16_t)rDescTabInd withDescTabSubindex:(Byte)rDescTabSubi descTabVal:(int16_t *) rPDeecTabV descTabString:(NSString **)rPDescTabStr;

//读位域描述的位和对应描述索引的数组
- (NSString *)readBitFieldTabsWithBitFieldIndex:(uint16_t)rBitFieldIndex bitFieldTabs:(WJCDescBitFieldTabs **)rPBitFieldTabs;

/*
 3.2.读组信息
 */
//读组内所有参数索引号
- (NSString *)readGroupContentWithUserLevel:(Byte)rUserLevel withGroupIndex:(Byte)rGroupInd groupContent:(NSMutableArray **)rPGroupContent;

//读组全称
- (NSString *)readGroupFullNameWithUserLevel:(Byte)rUserLevel withGroupIndex:(Byte)rGroupInd groupFullName:(NSString **)rPFullName;

//读组简称
- (NSString *)readGroupShortNameWithUserLevel:(Byte)rUserLevel withGroupIndex:(Byte)rGroupInd groupShortName:(NSString **)rPShortName;

/*
 3.3.读单个参数信息
 */
//读最大值
- (NSString *)readParaMaxWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi maxData:(NSMutableArray **)rPMaxData;

//读最小值
- (NSString *)readParaMinWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi minData:(NSMutableArray **)rPMinData;

//读默认值
- (NSString *)readParaDefaultWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi defaultData:(NSMutableArray **)rPDefaultData;

//读参数描述
- (NSString *)readParaDescWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi descbContent:(NSString **)rPDescb;

//读矩阵参数宽度和长度
- (NSString *)readArrayParaInfoWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi arrayWidth:(uint16_t *)rPWidth arrayLength:(uint16_t *)rPLength;

//读参数属性
- (NSString *)readParaAttributeWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi attrStruct:(WJCAddrStruct *)rPAttrStuct;

/*
 4.曲线采集协议
 */
- (void)recordHeartBeat;
//record模式开启和关闭
- (NSString *)recordModeOn;
- (NSString *)recordModeOff;
- (NSMutableData *)readRemoteRecordChannelDatas;
//读offline channel
- (NSString *)readOfflineChannelWithChannelIndex:(Byte)rChannelI pDataByte:(NSMutableData * *)rPData;
@end
