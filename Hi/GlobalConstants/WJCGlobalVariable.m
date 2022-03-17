//
//  WJCGlobalVariable.m
//  Hi
//
//  Created by apple on 2018/2/28.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCGlobalVariable.h"

NSObject *globelMutexTest;

@implementation WJCGlobalVariable

-(instancetype)init{
    if (self = [super init]) {
        mutex = [[NSObject alloc] init];
    }
    return self;
}

@end
