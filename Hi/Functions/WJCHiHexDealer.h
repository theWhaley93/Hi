//
//  WJCHiHexDealer.h
//  Hi
//
//  Created by apple on 2018/2/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJCHiHexDealer : NSCachedURLResponse

+ (NSString *)fixZero:(NSString *)ins radixPos:(int)ratio fix5:(Boolean)fix;    //default fix5=YES 默认fix值为yes

@end
