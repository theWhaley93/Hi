//
//  WJCDescTab.h
//  Hi
//
//  Created by apple on 2018/3/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCDescTabItem.h"



/**
 某个参数的描述表
 */
@interface WJCDescTab : NSObject{
    
}

@property (nonatomic,strong)  NSMutableArray<WJCDescTabItem *> * items;     //该参数所有值，对应的描述


/**
 初始化
 */
+ (instancetype)descTabWithString:(NSString *) str;
- (instancetype)initWithString:(NSString *) str;

/**方法
 */
- (NSString *)toString;

@end
