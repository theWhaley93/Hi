//
//  WJCDescIndexItem.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescIndexItem.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescIndexItem

/** 初始化
 */
- (instancetype)initWithString:(NSString *)str{
    if (self = [super init]) {
        index = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"ind"] intValue];
        descIndex = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"dind"] intValue];
    }
    return self;
}

+ (instancetype)descIndexItemWithString:(NSString *)str{
    return [[WJCDescIndexItem alloc] initWithString:str];
}
/**方法
 */
- (NSString *)toString{
    NSString *contentString = @"";
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",index] withTittleString:@"ind"]];
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",descIndex] withTittleString:@"dind"]];
    return contentString;
}
@end
