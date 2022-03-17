//
//  WJCDeviceFinder.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCWifiDeviceInfo.h"

@interface WJCDeviceFinder : NSObject

/**类方法，获取广播地址
 */
+ (NSString*)getBroadcastAddr;

/**初始化
 */
- (instancetype)initWithIp:(NSString *)ip;

+ (instancetype)deviceFinderWithIp:(NSString *)ip;

/**对象方法
 */
- (NSMutableArray<WJCWifiDeviceInfo *> *) getWifiDevices;

@end
