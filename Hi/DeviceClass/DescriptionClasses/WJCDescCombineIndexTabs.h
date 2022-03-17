//
//  WJCDescCombineIndexTabs.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCDescBitFieldTabs.h"

@interface WJCDescCombineIndexTabs : NSObject

@property (nonatomic,strong)  NSMutableArray<WJCDescBitFieldTabs *> *items;  //


- (instancetype)initWithString:(NSString *) str;

+ (instancetype)descCombineIndexTabsWithString:(NSString *) str;

/** 方法
 */
- (NSString *)toString;

@end
