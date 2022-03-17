//
//  WJCIpInformation.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NET_NONE, NET_WWAN, NET_WIRED, NET_WIFIAP, NET_WIFISTA
}WJCNetMode;

@interface WJCIpInformation : NSObject{
    @public
    NSString * addrInfoName;
    NSString * ipAddress;
    NSString * subNetMask;
    NSString * broadcastAddress;
    WJCNetMode netMode;
}

@end
