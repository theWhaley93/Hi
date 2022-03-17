//
//  WJCHiChart.m
//  Hi
//
//  Created by apple on 2018/5/16.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCHiChart.h"
#import "WJCHiFileExecutor.h"

@implementation WJCHiChart


- (void)fromString:(NSString*)rStr{
    _name = [WJCHiFileExecutor getTagetStringFrom:rStr cutString:@"name"];
}

- (instancetype)initWithString:(NSString*)rStr{
    if (self = [super init]) {
        [self fromString:rStr];
    }
    return self;
}

+ (instancetype)hiChartWithStr:(NSString*)rStr{
    return [[WJCHiChart alloc] initWithString:rStr];
}

@end
