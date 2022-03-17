//
//  WJCDescCombineIndexTabs.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescCombineIndexTabs.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescCombineIndexTabs


- (instancetype)initWithString:(NSString *) str{
    if (self = [super init]) {
        
        int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"combicount"] intValue];
        _items = [[NSMutableArray alloc] initWithCapacity:num];
        
        for (int i=0; i<num; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"combiitem%d",i]];
            
            WJCDescBitFieldTabs *tempItem = [WJCDescBitFieldTabs descBitFieldTabsWithString:tempS];
            [_items addObject:tempItem];
        }
    }
    return self;
}

+ (instancetype)descCombineIndexTabsWithString:(NSString *) str{
    return [[WJCDescCombineIndexTabs alloc] initWithString:str];
}

/** 方法
 */
- (NSString *)toString{
    NSString *contentString = @"";
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_items.count] withTittleString:@"combicount"]];
    
    for (int i=0; i<_items.count; i++) {
        contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[_items[i] toString] withTittleString:[NSString stringWithFormat:@"combiitem%d",i]]];
    }
    
    return contentString;
}

@end
