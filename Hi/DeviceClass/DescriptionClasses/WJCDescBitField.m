//
//  WJCDescBitField.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescBitField.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescBitField



- (instancetype)initWithString:(NSString *) str{
    if (self = [super init]) {
        len = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"len"] intValue];
        index = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"ind"] intValue];
    }
    return self;
}

+ (instancetype)descBitFieldWithString:(NSString *) str{
    return [[WJCDescBitField alloc] initWithString:str];
    
}
/** 方法
 */
- (NSString *)toString{
    NSString *contentString = @"";
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",len] withTittleString:@"len"]];
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",index] withTittleString:@"ind"]];
    
    return contentString;
}

@end
