//
//  WJCDescBitFieldTabs.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescBitFieldTabs.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescBitFieldTabs


- (instancetype)initWithString:(NSString *) str{
    if (self = [super init]) {
        
        int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"bitfiledcount"] intValue];
        _items = [[NSMutableArray alloc] initWithCapacity:num];
        
        for (int i=0; i<num; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"bitfiled%d",i]];
            
            WJCDescBitField *tempItem = [WJCDescBitField descBitFieldWithString:tempS];
            [_items addObject:tempItem];
        }
    }
    return self;
}

+ (instancetype)descBitFieldTabsWithString:(NSString *) str{
    return [[WJCDescBitFieldTabs alloc] initWithString:str];
}

/** 方法
 */
- (NSString *)toString{
    NSString *contentString = @"";
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_items.count] withTittleString:@"bitfiledcount"]];
    
    for (int i=0; i<_items.count; i++) {
        contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[_items[i] toString] withTittleString:[NSString stringWithFormat:@"bitfiled%d",i]]];
    }
    
    return contentString;
}
@end
