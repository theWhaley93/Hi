//
//  WJCHiChart.h
//  Hi
//
//  Created by apple on 2018/5/16.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJCHiChart : NSObject

@property (nonatomic,copy)  NSString *name;    //worklist的名称

- (void)fromString:(NSString*)rStr;

- (instancetype)initWithString:(NSString*)rStr;

+ (instancetype)hiChartWithStr:(NSString*)rStr;

@end
