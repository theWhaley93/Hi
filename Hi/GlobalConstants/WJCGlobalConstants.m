//
//  WJCGlobalConstants.m
//  udp
//
//  Created by apple on 2018/2/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCGlobalConstants.h"

/**驱动器常用固化参数
 */
uint16_t const INV_CFGID_INDEX = 4;
uint16_t const INV_MAXPARALIST_INDEX = 5;
uint16_t const INV_MAXGROUP_INDEX = 6;
uint16_t const INV_CHARTCMD_INDEX = 39;
uint16_t const INV_ERRCODE_INDEX = 97;
uint16_t const INV_HINT_INDEX = 96;
uint16_t const INV_BAUD_INDEX = 19;
uint16_t const INV_MAXDESCTAB_INDEX = 11;
uint16_t const INV_MAXDESCINDEX_INDEX = 10;
uint16_t const INV_MAXCOMBINEINDEX_INDEX = 13;
uint16_t const INV_SOFTENABLE_INDEX = 17;
uint16_t const INV_CFGDESC_INDEX = 65;

/** 通讯模块使用的常量
 */
double const READTIMEOUT = 0.3;
double const TIMEOUT = 0.5;     //读取通讯超时时间(单位：秒S)
double const WRITETIMEOUT = 0.5;  //写入动作的 超时时间
double const OFFLINECHANNELTIMEOUT = 5;     //离线曲线超时

NSString * const COMM_NONE = @"COMM_NONE";             //无状态
NSString * const COMM_SUC = @"COMM_SUCCESS";           //通讯成功，且有正常返回
NSString * const COMM_INVBUSY = @"COMM_INVBUSY";       //通讯成功，但返回驱动器忙错误，F6
NSString * const COMM_OTHERFAIL = @"COMM_OTHERFAIL";   //通讯成功，但返回其他错误
NSString * const COMM_TIMEOUT = @"COMM_TIMEOUT";       //通讯失败，超时
NSString * const COMM_CHKERR = @"COMM_CHECKERROR";     //通讯失败，校验错误

/** 字符串解析
 */
NSString * const NOT_FOUND = @"NOT_FOUND";  //没找到该条字符串


/** 标幺系数
 */
NSInteger const Q14 = 16383;    //
NSInteger const Q30 = 1073741823;    //
float const SQR2 = 1.41421;    //
NSInteger const Q32 = 0xFFFFFFFF;   //

/** 
 */


