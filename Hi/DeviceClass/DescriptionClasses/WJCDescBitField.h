//
//  WJCDescBitField.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJCDescBitField : NSObject{
    
@public
    uint16_t len;
    uint16_t index;         //desctab 的索引，对应描述列表的索引
}

- (instancetype)initWithString:(NSString *) str;

+ (instancetype)descBitFieldWithString:(NSString *) str;

/** 方法
 */
- (NSString *)toString;

@end
