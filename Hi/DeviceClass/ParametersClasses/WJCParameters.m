//
//  WJCParameters.m
//  Hi
//
//  Created by apple on 2018/2/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCParameters.h"
#import "WJCHiFileExecutor.h"
#import "WJCGlobalConstants.h"
#import "WJCOneGroup.h"


@interface WJCParameters(){
    
}

@end


@implementation WJCParameters

/** 属性的读取或者写入方法
 */
- (NSInteger)groupsCount{
    return _actualGroup.count;
}

- (NSInteger)parasCount{
    return _paras.count;
}

/** 初始化
 */

//根据index获取某个参数
- (WJCOneParameter *)getOneParaWithIndex:(uint16_t)rIndex{
    if (rIndex >= _paras.count) {
        return nil;
    } else
        return _paras[rIndex];
}

- (instancetype)initWithString:(NSString *)str{
    if (self = [super init]) {
        _configDescription = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"cfgdesc"];
        if ([_configDescription isEqualToString:NOT_FOUND]) {
            _configDescription = @"无驱动器版本描述信息";
        }
        
        NSInteger parasNum = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"addresscount"] intValue];
        _paras = [[NSMutableArray alloc] initWithCapacity:parasNum];
        WJCOneParameter *tempOnePara1 = [[WJCOneParameter alloc] init];
        for (int i = 0; i<parasNum; i++) {
            [_paras addObject:tempOnePara1];
        }
        
        NSInteger groupsNum = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"groupcount"] intValue];
        _actualGroup = [[NSMutableArray alloc] initWithCapacity:groupsNum];
        
        for (int i=0; i<groupsNum; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"group%d",i]];
            WJCOneGroup *tempOneGroup = [WJCOneGroup oneGroupWithString:tempS];
            [_actualGroup addObject:tempOneGroup];
            for (int j = 0; j<tempOneGroup.items.count; j++) {
                NSString *tempOneStr = [WJCHiFileExecutor getTagetStringFrom:tempS cutString:[NSString stringWithFormat:@"elements%d",j]];
                WJCOneParameter *tempOnePara = [WJCOneParameter oneParameterWithString:tempOneStr];
                [_paras replaceObjectAtIndex:tempOnePara.index withObject:tempOnePara];
            }
        }
        
    }
    return self;
}

+ (instancetype)parametersWithString:(NSString *)str{
    return [[WJCParameters alloc] initWithString:str];
    
}

/** 初始化
 */
- (NSString *)toString{
    NSString *contentString = @"";
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_configDescription withTittleString:@"cfgdesc"]];
    
     contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_paras.count] withTittleString:@"addresscount"]];
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_actualGroup.count] withTittleString:@"groupcount"]];
    
    
    for (int i=0; i<_actualGroup.count; i++) {
        contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[_actualGroup[i] toStringWithAllParas:_paras] withTittleString:[NSString stringWithFormat:@"group%d",i]]];
    }
    
    return contentString;
}

@end






