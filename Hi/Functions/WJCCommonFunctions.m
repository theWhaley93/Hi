//
//  WJCCommonFunctions.m
//  Hi
//
//  Created by apple on 2018/2/24.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCCommonFunctions.h"
#import "WJCGlobalConstants.h"

Boolean notErr(NSString * str){
    if ([str isEqualToString:COMM_NONE] || [str isEqualToString:COMM_INVBUSY] || [str isEqualToString:COMM_OTHERFAIL] || [str isEqualToString:COMM_TIMEOUT] || [str isEqualToString:COMM_CHKERR] || [str isEqualToString:@""]){
        return NO;
    }
    return YES;
}


Boolean isErr(NSString * str){
    return (!notErr(str));
}



