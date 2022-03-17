//
//  WJCHiFileExecutor.h
//  Hi
//
//  Created by apple on 2018/1/23.
//  Copyright © 2018年 apple. All rights reserved.
//

//本类用来操作与Hi软件相关的文件：plst、dlst；worklist、chart、project

#import <Foundation/Foundation.h>

@interface WJCHiFileExecutor : NSObject
/**
 打开文件，plst，dlst
 */
+ (NSString *)openPlstFile:(uint32_t) cfgId error:(NSError **)err;
+ (NSString *)openDlstFile:(uint32_t) cfgId error:(NSError **)err;

/**
 从字符串中截取需要的字符，对于原plst，dlst文件
 例如从<\addresscount\>1502</addresscount/>中截取1502
 
 @param wholeString 待处理的字符串
 @param cutString 输入标示字符串 例如addresscount
 @return 目标字符串,没找到返回Not_Found
 */
+ (NSString *)getTagetStringFrom: (NSString *) wholeString cutString:(NSString *)cutString;

//创建<//>结构的内容
+ (NSString *)makeTargetStringWithContentString:(NSString *)rContentStr withTittleString:(NSString *)tTittleStr;

/* 查询本地是否有plst和dlst文件
 */
+ (Boolean)searchCfgFilesLocal:(int)rCfgId;

//+ (NSError *)fileOpenError:(NSString *)errMsg;
/* 载入plst文件，如果本地有，从本地载入，如果没有从云端载入，如果云端也没有，显示没找到该文件
 */
+ (NSString *)loadPlstFile:(uint32_t) cfgId error:(NSError **)err;
@end
