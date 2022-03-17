//
//  WJCDeviceFinder.m
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCDeviceFinder.h"
#import "WJCIpInformation.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "GCDAsyncUdpSocket.h"

@interface WJCDeviceFinder()

@property (nonatomic,copy)  NSString *recvStr;    //
@property (nonatomic,copy)  NSString *BroadcastIp;    //广播地址
@property (nonatomic,strong)  GCDAsyncUdpSocket *udpSocket;  //udp
@property (nonatomic,strong)  NSMutableArray<WJCWifiDeviceInfo *> *wifiDevice;  //
@end

@implementation WJCDeviceFinder

/**类方法，获取广播地址
 */
+ (NSString*)getBroadcastAddr{
    NSString * address = @"";
    struct ifaddrs *interface = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSMutableArray<WJCIpInformation *> *tempAddrArray = [[NSMutableArray alloc] init];
    int success = 0;
    success = getifaddrs(&interface);
    if (success == 0) {
        temp_addr = interface;
        while (temp_addr != NULL) {
            if ((temp_addr->ifa_addr->sa_family == AF_INET) && ((temp_addr->ifa_flags & IFF_LOOPBACK)==0)) {
                WJCIpInformation * tempIpInfo = [[WJCIpInformation alloc] init];
                if (temp_addr->ifa_netmask) {
                    tempIpInfo->subNetMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                } else{
                    tempIpInfo->subNetMask = @"";
                }
                tempIpInfo->ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                tempIpInfo->addrInfoName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                tempIpInfo->broadcastAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    tempIpInfo->netMode = NET_WWAN;
                } else if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                    tempIpInfo->netMode = NET_WIRED;
                } else if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    tempIpInfo->netMode = NET_WIFISTA;
                } else if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"bridge100"]) {
                    tempIpInfo->netMode = NET_WIFIAP;
                }
                [tempAddrArray addObject:tempIpInfo];
            }
            temp_addr = temp_addr->ifa_next;
        }
        
    }
    
    if (tempAddrArray.count>0) {
        for (int i=0; i<tempAddrArray.count; i++) {
            switch (tempAddrArray[i]->netMode) {
                case NET_NONE:
                    break;
                case NET_WWAN:{
                    address = tempAddrArray[i]->broadcastAddress;
                    break;
                }
                case NET_WIRED:{
                    
                    break;
                }
                case NET_WIFIAP:{
                    address = tempAddrArray[i]->broadcastAddress;
                    return address;
//                    break;
                }
                case NET_WIFISTA:{
                    address = tempAddrArray[i]->broadcastAddress;
                    return address;
//                    break;
                }
            }
        }
    }
    return address;
}

/**初始化
 */
- (instancetype)initWithIp:(NSString *)ip{
    if (self = [super init]) {
//        NSError *error = nil;
//        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _BroadcastIp = ip;
        _wifiDevice = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)deviceFinderWithIp:(NSString *)ip{
    return [[WJCDeviceFinder alloc] initWithIp:ip];
}

/**对象方法
 */
- (NSMutableArray<WJCWifiDeviceInfo *> *) getWifiDevices{
//    NSMutableArray<WJCWifiDeviceInfo *> *resultWfiArray = [[NSMutableArray alloc] init];
    [_wifiDevice removeAllObjects];
    
    NSError *error = nil;
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.udpSocket bindToPort:400 error:&error];
//    if (error)
    {
        [self.udpSocket enableBroadcast:YES error:&error];
        [self.udpSocket beginReceiving:&error];

        NSString *msg = @"www.usr.cn";
        [self.udpSocket sendData:[msg dataUsingEncoding:NSUTF8StringEncoding] toHost:self.BroadcastIp port:48899 withTimeout:-1 tag:100];
    }
    
//    dispatch_queue_t queue = dispatch_queue_create("raceiveProcess", DISPATCH_QUEUE_SERIAL);
//    dispatch_sync(queue, ^{
//        CFTimeInterval start = CFAbsoluteTimeGetCurrent();
//        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
//        //判断是否超时
//        while ((end-start)<0.5) {
////            NSLog(@"%@",self.recvStr);
//            //当前时间
//            end = CFAbsoluteTimeGetCurrent();
//        }
//    });
//    [NSThread sleepForTimeInterval:0.5];
    NSLog(@"wait over");
    return _wifiDevice;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg) {
        WJCWifiDeviceInfo *tempDev = [[WJCWifiDeviceInfo alloc] init];
        NSArray *tempA = [msg componentsSeparatedByString:@","];
        if (tempA.count == 4) {
            tempDev.ip = tempA[0];
            tempDev.macIp = tempA[1];
            tempDev.name = tempA[2];
            tempDev.softwareVer = tempA[3];
            [_wifiDevice addObject:tempDev];
        }

        NSLog(@"RECV:%@",msg);
    }
//    self.recvStr = msg;
//    if (msg)
//    {
//        NSLog(@"RECV:%@",msg);
//
//    }
//    else
//    {
//        NSString *host = nil;
//        uint16_t port = 0;
//        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
//        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
//    }
}

@end
