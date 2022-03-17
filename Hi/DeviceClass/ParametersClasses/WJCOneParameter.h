//
//  WJCOneParameter.h
//  Hi
//
//  Created by apple on 2018/1/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCHiFileExecutor.h"




typedef struct _PerUnitValue{
    double maxSpeed;
    double ratedVoltage;
    double maxCurrent;
}WJCPerUnitValueStruct;

extern WJCPerUnitValueStruct nowPerUnit;

//参数显示的类型 十进制、十六进制
typedef enum {
    SHOWTYPE_DEC,SHOWTYPE_HEX
}WJCShowType;

//参数标幺基础类型
typedef enum {
    TBST_NONE,  TBST_SPEED,  TBST_CURRENT,  TBST_VOLTAGE,
    TBST_OTHER, TBST_VOLTAGE_S,  TBST_Q32
}WJCBasedType;

//参数基础数据类型
typedef enum {
    DT_VOID,  DT_BOOL, DT_SINT,  DT_INT,   DT_DINT,  DT_LINT,
    DT_USINT, DT_UINT, DT_UDINT, DT_ULINT, DT_REAL,  DT_LREAL,
    DT_TIME,  DT_DATE, DT_TIME_OF_DAY, DT_DATE_AND_TIME,  DT_STRING, DT_BYTE, DT_WORD,
    DT_DWORD, DT_LWORD, DT_ERRCODE
}WJCDataType;

//参数描述类型，DDT_NONE 普通无描述参数；DDT_NONE_BIT 按位走无描述的参数；DDT_DESC_NORMAL 普通参数描述；DDT_DESC_BIT 按位走的描述，每个位有描述； DDT_DESC_BITS 多个位组合成一个描述
typedef enum {
    DDT_NONE, DDT_NONE_BIT, DDT_DESC_NORMAL, DDT_DESC_BIT, DDT_DESC_BITS
}WJCDateDescType;


//
typedef struct _WJCAddrStruct {
    uint32_t attribute;
    WJCDataType dataType;
    uint8_t res1;
    uint16_t vDiv;
    uint16_t vMul;
} WJCAddrStruct;

//解析addrstruct的字符串内容，转成结构
NS_INLINE WJCAddrStruct WJCMakeAddrStruct(NSString *addrStructStr) {
    WJCAddrStruct r;
    NSRange range;

    if ([addrStructStr length] == 24) {
        NSMutableArray *strArray = [[NSMutableArray alloc] init];
        for (int i=0; i<12; i++) {
            range = NSMakeRange(2*i, 2);
            [strArray addObject:[addrStructStr substringWithRange:range]];
        }
        
        NSString *attrStr = @"";
        for (int i=0; i<4; i++) {
            attrStr = [attrStr stringByAppendingString:(NSString *)strArray[4-i-1]];
        }
        
        NSString *dateTypeStr = (NSString *)strArray[4];
        NSString *res1Str = (NSString *)strArray[5];
        
        NSString *vDivStr = @"";
        for (int i=0; i<2; i++) {
            vDivStr = [vDivStr stringByAppendingString:(NSString *)strArray[8-i-1]];
        }
        
        NSString *vMulStr = @"";
        for (int i=0; i<2; i++) {
            vMulStr = [vMulStr stringByAppendingString:(NSString *)strArray[10-i-1]];
        }
        
//        NSMutableData *data = [[NSMutableData alloc] init];
//        NSString *testStr = @"00061080";
        r.attribute = strtoul([attrStr UTF8String], 0, 16);
        r.dataType = strtoul([dateTypeStr UTF8String], 0, 16);
        r.res1 = strtoul([res1Str UTF8String], 0, 16);
        r.vDiv = strtoul([vDivStr UTF8String], 0, 16);
        r.vMul = strtoul([vMulStr UTF8String], 0, 16);
//        [data appendBytes:&r.attribute length:sizeof(r.attribute)];

    } else{
        
    }
    
    return r;
}
//addrstruct的内容转成结字符串
NS_INLINE NSString* WJCMakeAddrStructToString(WJCAddrStruct rAttrStuct){
    NSString *resultContent = @"";
    for (int i=0; i<4; i++) {
        resultContent = [resultContent stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&rAttrStuct.attribute))[i]]];
    }
    resultContent = [resultContent stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&rAttrStuct.dataType))[0]]];
    resultContent = [resultContent stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&rAttrStuct.res1))[0]]];
    for (int i=0; i<2; i++) {
        resultContent = [resultContent stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&rAttrStuct.vDiv))[i]]];
    }
    for (int i=0; i<2; i++) {
        resultContent = [resultContent stringByAppendingString:[NSString stringWithFormat:@"%02X",((Byte *)(&rAttrStuct.vMul))[i]]];
    }
    resultContent = [resultContent stringByAppendingString:@"0000"];
    return resultContent;
}




@interface WJCOneParameter : NSObject{
    

    NSString * readHex;     //实际读到的值，十六进制用“,”和“|”分隔
    
    @public
    WJCAddrStruct actData;
    uint32_t groupIndex;
    uint32_t groupSubindex;
    
    Byte max[8];    //最大值
    Byte min[8];    //最小值
    Byte defaultVal[8];     //默认值
    
    uint16_t arrayWidth;    //矩阵宽度
    uint16_t arrayLength;   //矩阵深度

}
/** 短名 */
@property (nonatomic,copy)  NSString *sDescribe;
/** 长名 */
@property (nonatomic,copy)  NSString *lDescribe;
/** 索引 */
@property (nonatomic)  uint16_t index;
/** 最大值 */

/** 最小值 */

/** 默认值 */


/** 实际读到的值 */
@property (nonatomic,copy,readonly)  NSString *usedReadHex;
/** 存的离线值 */
@property (nonatomic,copy)  NSString *offlineVal;


/** 矩阵参数 */
@property (nonatomic,readonly)  uint32_t arrayCount;

/* 标幺类型属性
 */
@property (nonatomic,readonly)   WJCBasedType basedType;    //标幺类型
@property (nonatomic,readonly,copy)   NSString *basedTypeString;//标幺的文字描述
@property (nonatomic,copy,readonly)  NSString *realSymbol;    //标幺符号

/* 值类型
 */
@property (nonatomic,strong,readonly)  NSArray *dsDataType;  //数据类型描述，不可修改 固定
@property (nonatomic,readonly)   WJCDataType typ;    //类型标识符
@property (nonatomic,readonly)   uint32_t len;    //参数长度
@property (nonatomic,copy,readonly)   NSString *typeString;    //类型的文字描述
@property (nonatomic,copy,readonly)  NSString *attributeString;    //属性的文字描述
@property (nonatomic,readonly)   Boolean sign;    //正负符号
@property (nonatomic,readonly)   Boolean isDate;    //是否日期

@property (nonatomic,readonly)   uint32_t radixPointPos;    //小数点位置（0，1，2，3）
@property (nonatomic,readonly,copy)   NSString *symbol;    //显示符号

@property (nonatomic,readonly)   Boolean isReadonly;    //是否只读
@property (nonatomic,readonly)   Boolean isArray;    //是否矩阵
@property (nonatomic,readonly)   Boolean isDataSet;    //是否有子索引
@property (nonatomic,readonly)   Boolean isRetain;    //是否可以保存

@property (nonatomic,readonly)   uint32_t access;    //权限类型
@property (nonatomic,readonly)   uint32_t descType;    //描述类型
@property (nonatomic,readonly)   WJCDateDescType descTypeEnum;    //描述类型,枚举返回
@property (nonatomic,readonly)   uint32_t level;    //用户级别

@property (nonatomic,readonly)   uint32_t vMul;    //乘数
@property (nonatomic,readonly)   uint32_t vDiv;    //除数

@property (nonatomic,copy,readonly)  NSString *describe;    //长描述
@property (nonatomic,copy,readonly)  NSString *wDescribe;    //全部描述

@property (nonatomic,copy,readonly)  NSString *setDisp;    //离线设置值显示
@property (nonatomic,readonly)   uint32_t intVal;    //数字值

@property (nonatomic,readonly)   double defVal;    //默认值的数字值方式
@property (nonatomic,readonly,copy)   NSString *defStr;    //默认值的文字方式
@property (nonatomic,readonly,copy)   NSString *defHex;    //默认值的十六进制
@property (nonatomic,readonly,copy)   NSString *defHexString;    //默认值的十六进制 按八个字节长度
@property (nonatomic,readonly)  NSString *defStrNew;  //带分隔符的默认值


@property (nonatomic)   double minVal;    //最小值的数字值方式
@property (nonatomic,readonly,copy)   NSString *minStr;    //最小值的文字方式
@property (nonatomic,readonly,copy)   NSString *minHex;    //最小值的十六进制
@property (nonatomic,readonly,copy)   NSString *minHexString;    //最小值的十六进制 按八个字节长度

@property (nonatomic)   double maxVal;    //最大值的数字值方式
@property (nonatomic,readonly,copy)   NSString *maxStr;    //最大值的文字方式
@property (nonatomic,readonly,copy)   NSString *maxHex;    //最大值的十六进制
@property (nonatomic,readonly,copy)   NSString *maxHexString;    //最大值的十六进制 按八个字节长度

@property (nonatomic,readonly)   Boolean isHex;    //是否十六进制
@property (nonatomic,readonly)   Boolean isString;    //是否字符串类型
@property (nonatomic,readonly)   Boolean isFloat;    //是否浮点型
@property (nonatomic,copy,readonly)  NSString *indexStr;    //索引的字符显示方式

/* 手机端增加每个参数的显示方式：十进制、十六进制
 */
@property (nonatomic)  WJCShowType showType;  //显示方式

//hex值的交换
- (NSString *)valHexWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd;
- (void)setValHexWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd val:(NSString *) valH;

//string值的交换
- (NSString *)valStrWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd;
- (void)setValStrWithSubindex:(uint32_t) subindex withArrayIndex:(uint32_t) arrayInd val:(NSString *) valS;

#pragma mark-初始化类
/**
 解析、生成字符串
 */
- (Boolean)fromString:(NSString *) str;
- (NSString *)toString;

/**
 初始化类
 */
- (instancetype)initWithString:(NSString *) str;

+ (instancetype)oneParameterWithString:(NSString *) str;

#pragma mark-其他函数方法
- (NSString *)strToHex:(NSString *) s;

- (NSString *)hexToStr:(NSString *) s;

- (NSString *)fixHexLen:(NSString *) s;

- (void)initReadHex;

- (void)initDefaultNewStr;

- (NSString *)showParaDesc:(NSString *)val descD:(NSObject *)descr;

- (NSString *)showParaWithoutDesc:(NSString *)val descD:(NSObject *)descr;
@end


extern NSString * hexToDisp(NSString * valStr, WJCOneParameter * addr);
extern NSString * dispToHex(NSString *s, WJCOneParameter *addr);


