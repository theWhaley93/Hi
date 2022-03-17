//
//  WJCDescIndexTabs.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCDescIndexItem.h"

@interface WJCDescIndexTabs : NSObject{
    
}

@property (nonatomic,strong)  NSMutableArray<WJCDescIndexItem *> *items;  //索引号对应 描述索引表
/** 初始化
 */
- (instancetype)initWithString:(NSString *) str;

+ (instancetype)descIndexTabsWithSring:(NSString *)str;

/** 方法
 */
- (NSString *)toString;
@end
