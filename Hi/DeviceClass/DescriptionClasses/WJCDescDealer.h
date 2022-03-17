//
//  WJCDescDealer.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCDescCombineIndexTabs.h"
#import "WJCDescIndexTabs.h"
#import "WJCDescTabs.h"
#import "WJCOneParameter.h"

@interface WJCDescDealer : NSObject

@property (nonatomic,strong)  WJCDescIndexTabs *descIndexes;  //
@property (nonatomic,strong)  WJCDescTabs *descTabs;  //
@property (nonatomic,strong)  WJCDescCombineIndexTabs *combineIndexes;  //位

/** 对象方法
 */
- (void)fromstring:(NSString *)str;     //从字符串中解析

- (NSString *)getDescFromDescInd:(uint16_t)dind fromVal:(NSString *)val;

- (NSString *)getDescFromDescInd:(uint16_t)dind fromIo:(NSString *)hex;

- (int)getDescIndexFromInd:(uint16_t)ind;

- (NSString *)descriptionFromValue:(NSString *)val fromAddr:(WJCOneParameter *)addr;

- (NSString *)toString; //  生成字符串

/** 初始化
 */
- (instancetype)initWithString:(NSString *)str;

+ (instancetype)descDealerWithString:(NSString *)str;

@end
