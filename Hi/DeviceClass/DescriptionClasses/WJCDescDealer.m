//
//  WJCDescDealer.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDescDealer.h"
#import "WJCHiFileExecutor.h"

@implementation WJCDescDealer

/** 初始化
 */
- (instancetype)init{
    self.descIndexes = [[WJCDescIndexTabs alloc] init];
    self.descTabs = [[WJCDescTabs alloc] init];
    self.combineIndexes = [[WJCDescCombineIndexTabs alloc] init];
    return self;
}

- (instancetype)initWithString:(NSString *)str{
    if (self = [super init]) {
        [self fromstring:str];
    }
    return self;
}

+ (instancetype)descDealerWithString:(NSString *)str{
    return [[WJCDescDealer alloc] initWithString:str];
}

/** 对象方法
 */
- (void)fromstring:(NSString *)str{
    NSString *tpS = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"descs"];
    self.descTabs = [WJCDescTabs descTabsWithString:tpS];
    
    
    NSString *tpDesInd = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"indexs"];
    self.descIndexes = [WJCDescIndexTabs descIndexTabsWithSring:tpDesInd];
    
    
    NSString *tpComInd = [WJCHiFileExecutor getTagetStringFrom:str cutString:@"bits"];
    self.combineIndexes = [WJCDescCombineIndexTabs descCombineIndexTabsWithString:tpComInd];
    

}

- (NSString *)toString{
    NSString *contentStr = @"";
    
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[self.descIndexes toString] withTittleString:@"indexs"]];
    
    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[self.descTabs toString] withTittleString:@"descs"]];

    contentStr = [contentStr stringByAppendingString:[WJCHiFileExecutor makeTargetStringWithContentString:[self.combineIndexes toString] withTittleString:@"bits"]];
    
    return contentStr;
}


- (NSString *)getDescFromDescInd:(uint16_t)dind fromVal:(NSString *)val{
    NSString * resultStr = @"";
    int v = [val intValue];
    for (int i=0; i<_descTabs.items[dind].items.count; i++) {
        if (v == _descTabs.items[dind].items[i]->value) {
            resultStr = _descTabs.items[dind].items[i]->desc;
            break;
        }
    }
    return resultStr;
}

- (NSString *)getDescFromDescInd:(uint16_t)dind fromIo:(NSString *)hex{
    NSString * resultStr = @"";
    int16_t v = strtoul([hex UTF8String], 0, 16);
    for (int i=0; i<_descTabs.items[dind].items.count; i++) {
        if (((v >> (_descTabs.items[dind].items[i]->value)) & 1) == 1) {
            resultStr =[resultStr stringByAppendingString:[NSString stringWithFormat:@"+%@",_descTabs.items[dind].items[i]->desc]];
        }
    }
    if ([resultStr isEqualToString:@""]) {
        return resultStr;
    }
    
    NSRange tempRange = NSMakeRange(0, 1);
    if ([[resultStr substringWithRange:tempRange] isEqualToString:@"+"]) {
        resultStr = [resultStr substringFromIndex:1];
    }
    return resultStr;
}

- (int)getDescIndexFromInd:(uint16_t)ind{
    int resultN = -1;
    for (int i = 0; i<_descIndexes.items.count; i++) {
        if (ind == (_descIndexes.items[i]->index)) {
            resultN = _descIndexes.items[i]->descIndex;
            break;
        }
    }
    return resultN;
}

- (NSString *)descriptionFromValue:(NSString *)val fromAddr:(WJCOneParameter *)addr{
    NSString *resultStr = @"";
    if (addr.isFloat) {
        return resultStr;
    }
    if ([val isEqualToString:@""]) {
        return resultStr;
    }
    
    for (int i=0; i<_descIndexes.items.count; i++) {
        if (addr.index == _descIndexes.items[i]->index) {
            if (addr.descType == 1) {
                resultStr = [self getDescFromDescInd:_descIndexes.items[i]->descIndex fromVal:val];
            } else if (addr.descType == 2) {
                resultStr = [self getDescFromDescInd:_descIndexes.items[i]->descIndex fromIo:val];
            }
            break;
        }
    }
    
    return resultStr;
}

@end
