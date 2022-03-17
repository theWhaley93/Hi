//
//  WJCOneGroup.m
//  Hi
//
//  Created by apple on 2018/2/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCOneGroup.h"
#import "WJCHiFileExecutor.h"
#import "WJCGlobalConstants.h"


@interface WJCOneGroup()

@end

@implementation WJCOneGroup

/*属性方法
 */
- (NSInteger)itemsCount{
    return _items.count;
}

- (NSInteger)visibleItemsCount{
    return _visibleItems.count;
}

/** 初始化
 */
- (instancetype)initWithString:(NSString *)str{
    if (self = [super init]) {
        self.fullName = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"sectorname"];
        self.abbreviativeName = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"sname"];
        
        int num = [[WJCHiFileExecutor getTagetStringFrom:str cutString:@"count"] intValue];
        _items = [[NSMutableArray alloc] initWithCapacity:num];
        
        _visibleItems = [[NSMutableArray alloc] init];
        
        for (int i=0; i<num; i++) {
            NSString *tempS = [WJCHiFileExecutor getTagetStringFrom:str cutString:[NSString stringWithFormat:@"elements%d",i]];
            uint16_t tempIndex = [[WJCHiFileExecutor getTagetStringFrom:tempS cutString:@"index"] intValue];
            if ([_abbreviativeName isEqualToString:@""]) {
                NSString *tempSname = [WJCHiFileExecutor getTagetStringFrom:tempS cutString:@"sdesc"];
                if (![tempSname isEqualToString:@""])
                    _abbreviativeName = [tempSname substringWithRange:NSMakeRange(0, 2)];
            }
            WJCGroupItem *tempItem = [WJCGroupItem groupItemWithindex:tempIndex name:[NSString stringWithFormat:@"%@%02d",_abbreviativeName,i]];
            [_items addObject:tempItem];
            if (tempIndex != 0) {
                [_visibleItems addObject:tempItem];
            }
            
        }

    }
    return self;
}

+ (instancetype)oneGroupWithString:(NSString *)str{
    return [[WJCOneGroup alloc] initWithString:str];
}
/** 方法
 */
- (NSString *)toStringWithAllParas:(NSMutableArray<WJCOneParameter *> *)rAllParas{
    NSString *contentString = @"";
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_fullName withTittleString:@"sectorname"]];
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:_abbreviativeName withTittleString:@"sname"]];
    
    contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[NSString stringWithFormat:@"%ld",_items.count] withTittleString:@"count"]];
    
    
    for (int i=0; i<_items.count; i++) {
        contentString = [contentString stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[rAllParas[_items[i]->index] toString] withTittleString:[NSString stringWithFormat:@"elements%d",i]]];
    }
    
    return contentString;
}


@end
