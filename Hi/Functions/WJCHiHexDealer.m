//
//  WJCHiHexDealer.m
//  Hi
//
//  Created by apple on 2018/2/26.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCHiHexDealer.h"

@implementation WJCHiHexDealer

+ (NSString *)fixZero:(NSString *)ins radixPos:(int)ratio fix5:(Boolean)fix{    //default fix5=YES 默认fix值为yes
    NSString *resultStr = @"";
    
    NSRange tempRange = [ins rangeOfString:@"."];   //没截取到. 如果没截取到，location随机值，length为0
    
    if (ratio <= 0) {
        if (tempRange.length <= 0) {    //没截取到. 如果没截取到，location随机值，length为0
            resultStr = ins;
        } else {
            double d = [ins floatValue];
            resultStr = [NSString stringWithFormat:@"%.0f",d];
        }
    } else {
        if (tempRange.length <= 0) {    //没截取到. 如果没截取到，location随机值，length为0
            resultStr = [ins stringByAppendingString:@"."];
            for (int i=0; i<(ratio); i++) {
                resultStr = [resultStr stringByAppendingString:@"0"];
            }
        } else {
            NSInteger tt = [ins length];
            if ((tt - tempRange.location - 1) >= ratio) {
                NSRange range = NSMakeRange(0, tempRange.location+ratio+1);
                resultStr = [ins substringWithRange:range];
                if (fix) {
                    double d = [ins floatValue];
                    resultStr = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%d%@",@"%.",ratio,@"f"],d];
                }
            } else {
                resultStr = ins;
                for (int i=0; i<(ratio - ([ins length] - tempRange.location -1)); i++) {
                    resultStr = [resultStr stringByAppendingString:@"0"];
                }
                
            }
        }
        
    }
    
    return resultStr;
}

@end
