//
//  WJCDescTabs.h
//  Hi
//
//  Created by apple on 2018/3/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCDescTab.h"


/**
 所有有描述参数的表
 */
@interface WJCDescTabs : NSObject

@property (nonatomic,strong)  NSMutableArray<WJCDescTab *> *items;  //所有有描述参数的参数表

/** 初始化动作
 */
+ (instancetype)descTabsWithString:(NSString *) str;

- (instancetype)initWithString:(NSString *) str;


/**方法
 */
- (NSString *)toString;

@end
