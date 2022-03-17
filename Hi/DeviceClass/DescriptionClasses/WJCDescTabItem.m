//
//  WJCDescTabItem.m
//  Hi
//
//  Created by apple on 2018/3/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescTabItem.h"
#import "WJCHiFileExecutor.h"


@implementation WJCDescTabItem

- (NSString *)useString{
    return [NSString stringWithFormat:@"%d: %@",value,desc];
}

- (NSString *)useBitString{
    return [NSString stringWithFormat:@"bit%d  %@",value,desc];
}

/** 初始化
 */
+ (instancetype)descTabItemWithString:(NSString *)str{
    return [[WJCDescTabItem alloc] initWithSting:str];
}

- (instancetype)initWithSting:(NSString *)str{
    if (self = [super init]) {
        value = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"v"] intValue];
        desc = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"d"];
    }
    return self;
}

/**方法
 */
- (NSString *)toString{
    
    NSString *contentString = @"";
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%d",value] withTittleString:@"v"]];
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:desc withTittleString:@"d"]];
    
    return contentString;
}
@end
