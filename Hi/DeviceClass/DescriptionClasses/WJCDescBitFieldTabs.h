//
//  WJCDescBitFieldTabs.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCDescBitField.h"

@interface WJCDescBitFieldTabs : NSObject


@property (nonatomic,strong) NSMutableArray<WJCDescBitField *>  *items;  //

- (instancetype)initWithString:(NSString *) str;

+ (instancetype)descBitFieldTabsWithString:(NSString *) str;

/** 方法
 */
- (NSString *)toString;

@end
