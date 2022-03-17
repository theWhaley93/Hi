//
//  WJCDescIndexTabs.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescIndexTabs.h"
#import "WJCHiFileExecutor.h"


@implementation WJCDescIndexTabs



/** 初始化
 */
- (instancetype)initWithString:(NSString *) str{
    if (self = [super init]) {
        
        int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"count"] intValue];
        _items = [[NSMutableArray alloc] initWithCapacity:num];
        
        for (int i=0; i<num; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"item%d",i]];
            
             WJCDescIndexItem *tempItem = [WJCDescIndexItem descIndexItemWithString:tempS];
            [_items addObject:tempItem];
        }
    }
    return self;
}

+ (instancetype)descIndexTabsWithSring:(NSString *)str{
    return [[WJCDescIndexTabs alloc] initWithString:str];
}

/** 方法
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
