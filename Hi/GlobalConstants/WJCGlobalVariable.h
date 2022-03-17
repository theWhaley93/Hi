//
//  WJCGlobalVariable.h
//  Hi
//
//  Created by apple on 2018/2/28.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSObject *globelMutexTest;
@interface WJCGlobalVariable : NSObject{
    NSObject *mutex;
}

@end
