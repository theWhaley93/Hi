//
//  WJCGlobalConstants.h
//  udp
//
//  Created by apple on 2018/2/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#ifndef WJCGlobalConstants_h
#define WJCGlobalConstants_h

#define PGY_APPKEY @"1325b507df8808267eddff2f14011e5d"
/**驱动器常用固化参数
 */
extern uint16_t const INV_CFGID_INDEX;
extern uint16_t const INV_MAXPARALIST_INDEX;
extern uint16_t const INV_MAXGROUP_INDEX;
extern uint16_t const INV_CHARTCMD_INDEX;
extern uint16_t const INV_ERRCODE_INDEX;
extern uint16_t const INV_HINT_INDEX;
extern uint16_t const INV_BAUD_INDEX;
extern uint16_t const INV_MAXDESCTAB_INDEX;
extern uint16_t const INV_MAXDESCINDEX_INDEX;
extern uint16_t const INV_MAXCOMBINEINDEX_INDEX;
extern uint16_t const INV_SOFTENABLE_INDEX;
extern uint16_t const INV_CFGDESC_INDEX ;
/** 通讯模块使用的常量
 */
extern double const READTIMEOUT;
extern double const TIMEOUT;
extern double const WRITETIMEOUT;
extern double const OFFLINECHANNELTIMEOUT;
extern NSString * const COMM_NONE;       //无状态
extern NSString * const COMM_SUC;        //通讯成功，且有正常返回
extern NSString * const COMM_INVBUSY;    //通讯成功，但返回驱动器忙错误，F6
extern NSString * const COMM_OTHERFAIL;  //通讯成功，但返回其他错误
extern NSString * const COMM_TIMEOUT;    //通讯失败，超时
extern NSString * const COMM_CHKERR;     //通讯失败，校验错误

/** 字符串解析
 */
extern NSString * const NOT_FOUND;  //没找到该条字符串

/** 标幺系数
 */
extern NSInteger const Q14;    //
extern NSInteger const Q30;    //
extern float const SQR2;    //
extern NSInteger const Q32;   //

#endif /* WJCGlobalConstants_h */
