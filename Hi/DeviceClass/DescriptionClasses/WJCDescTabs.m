//
//  WJCDescTabs.m
//  Hi
//
//  Created by apple on 2018/3/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescTabs.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescTabs



/** 初始化动作
 */
- (instancetype)initWithString:(NSString *)str{
    if (self = [super init]) {
        int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"itemcount"] intValue];
        _items = [[NSMutableArray alloc] initWithCapacity:num];
        
        for (int i=0; i<num; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"desc%d",i]];
            
            WJCDescTab *tempItem = [WJCDescTab descTabWithString:tempS];
            [_items addObject:tempItem];
        }
    }
    return self;
}

+ (instancetype)descTabsWithString:(NSString *)str{
    return [[WJCDescTabs alloc] initWithString:str];
}

/**方法
 */
- (NSString *)toString{
    
    NSString *contentString = @"";
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_items.count] withTittleString:@"itemcount"]];
    
    for (int i=0; i<_items.count; i++) {
        contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[_items[i] toString] withTittleString:[NSString stringWithFormat:@"desc%d",i]]];
    }
    
    return contentString;
}

@end
