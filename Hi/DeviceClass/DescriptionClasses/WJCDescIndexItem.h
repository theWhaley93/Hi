//
//  WJCDescIndexItem.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJCDescIndexItem : NSObject{
    
    @public
    uint16_t index;
    uint16_t descIndex;
}

/** 初始化
 */
- (instancetype)initWithString:(NSString *)str;

+ (instancetype)descIndexItemWithString:(NSString *)str;

/**方法
 */
- (NSString *)toString;

@end
