//
//  WJCDescTab.m
//  Hi
//
//  Created by apple on 2018/3/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescTab.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescTab



/**
 初始化
 */
+ (instancetype)descTabWithString:(NSString *)str{
    return [[WJCDescTab alloc] initWithString:str];
}

- (instancetype)initWithString:(NSString *)str{
    if (self = [super init]) {
        int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"count"] intValue];
        _items = [[NSMutableArray alloc] initWithCapacity:num];
        
        for (int i=0; i<num; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"item%d",i]];
            
            WJCDescTabItem *tempItem = [WJCDescTabItem descTabItemWithString:tempS];
            [_items addObject:tempItem];
            
        }
    }
    return self;
}

/**方法
 */
- (NSString *)toString{
    
    NSString *contentString = @"";
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_items.count] withTittleString:@"count"]];
    
    for (int i=0; i<_items.count; i++) {
        
        contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[_items[i] toString] withTittleString:[NSString stringWithFormat:@"item%d",i]]];
        
    }
    
    return contentString;
}
@end
