//
//  WJCGroupItem.m
//  Hi
//
//  Created by apple on 2018/2/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCGroupItem.h"

@implementation WJCGroupItem

/**
 初始化类
 */
- (instancetype)initWithindex:(uint16_t)ind name:(NSString *)sname{
    if (self = [super init]) {
        index = ind;
        abbreviativeName = sname;
    }
    return self;
}

+ (instancetype)groupItemWithindex:(uint16_t)ind name:(NSString *)sname{
    return [[WJCGroupItem alloc] initWithindex:ind name:sname];
}

@end
