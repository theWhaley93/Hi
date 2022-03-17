//
//  WJCRemoteClass.m
//  remoteHi
//
//  Created by apple on 2018/5/28.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCRemoteClass.h"

Byte const PROTOCOLHEAD = 0x01;
double const REMOTETIMEOUT = 3;

@interface WJCRemoteClass()<GCDAsyncSocketDelegate>{
    NSThread *receiveNoticeDataThread;  //查询接收缓存，通知类型
    NSThread *receiveNeedAnswerDataThread;  //查询接收缓存，需要返回类型
    NSThread *receiveMNeedNoAnswerDataThread;  //查询接收缓存，不需要返回数据
    id<WJCRemoteDelegate> theDelegate;
    
    Byte cycleByte;
    dispatch_queue_t queue ;    //线程队列 实例化的时候创建
    
    NSMutableData *receiveData;  //接收的缓存
    //分类的接收数据缓存
    NSMutableArray<NSData *> *heartBeatCache;    //主指令0，心跳返回
    NSMutableArray<NSData *> *requestReturnCache;      //主指令1，被动端请求，服务器应答
    NSMutableArray<NSData *> *needAnswerCache;      //主指令2，主动端请求，被动端返回
    NSMutableArray<NSData *> *noticeCache;      //主指令5，通知被动端，无需返回
    NSMutableArray<NSData *> *notNeedAnswerCache;      //主指令6，主动端通知，不需要被动端返回
    
    NSLock *heartBeatLock;    //主指令0，锁
    NSLock *requestReturnLock;      //主指令1，锁
    NSLock *needAnswerLock;      //主指令2，锁
    NSLock *noticeLock;      //主指令5，锁
    NSLock *notNeedAnswerLock;      //主指令6，锁
    
    NSData *tempRequestReturnData;  //主指令1，子指令1的临时缓存
    
    //心跳定时器
    NSTimer *heartBeatTimer;
    
    
    //判断心跳是否在的临时变量
    Boolean tempHeartBeatConnect;
    Boolean heartBeatConnected;
    NSInteger heartBeatInv;
    
    //手动操作断开，此时不需要代理回界面
    Boolean notNeedDisconnectDelegate;
}

@end


@implementation WJCRemoteClass

#pragma mark - 初始化
- (void)initMembers{
    //tcp client初始化 接收代理初始化
    dispatch_queue_t testQueue = dispatch_queue_create("recvQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    _tcpClient = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:testQueue];
    
    queue = dispatch_queue_create("raceiveProcess", DISPATCH_QUEUE_SERIAL);
    //循环码初始化
    cycleByte = 0x00;
    
    //初始化数据缓存
    receiveData = [[NSMutableData alloc] init];
    heartBeatCache = [[NSMutableArray alloc] init];
    requestReturnCache = [[NSMutableArray alloc] init];
    needAnswerCache = [[NSMutableArray alloc] init];
    notNeedAnswerCache = [[NSMutableArray alloc] init];
    noticeCache = [[NSMutableArray alloc] init];
    
    heartBeatLock = [[NSLock alloc] init];
    requestReturnLock = [[NSLock alloc] init];
    needAnswerLock = [[NSLock alloc] init];
    noticeLock = [[NSLock alloc] init];
    notNeedAnswerLock = [[NSLock alloc] init];
    
    heartBeatConnected = NO;
    
//    receiveNoticeDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveNoticeDataThreadAction) object:nil];
    
}

#pragma mark - 初始化
- (instancetype)initWithDelegate:(id)rDelegate{
    if (self = [super init]) {
        theDelegate = rDelegate;
        [self initMembers];
    }
    return self;
}

- (void)enableHeartBeatTimer{
    float hSec = 1;
    if (heartBeatInv>2) {
        hSec = heartBeatInv - 2;
    }
    heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:hSec target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
    [heartBeatTimer setFireDate:[NSDate distantPast]];
}
#pragma mark - 状态
- (Boolean)remoteConnected{
    Boolean isCon = _tcpClient.isConnected;
    return (heartBeatConnected && isCon);
}
#pragma mark - 客户端请求动作
//连接动作
- (Boolean)connectToServer:(NSString *)rIp withPort:(uint16_t)rPort{
    NSError *error = nil;
//    if ([self.tcpClient connectToHost:@"101.37.83.8" onPort:10086 error:&error]) {
    if ([self.tcpClient connectToHost:rIp onPort:rPort error:&error]) {
        NSLog(@"connect successful");
        //必须添加readDataWithTimeout方法
        [self.tcpClient readDataWithTimeout:-1 tag:0];
        
        return YES;
    } else {
        NSLog(@"connect failed");
        return NO;
    }
}
//断开连接
- (void)diconnect{
    [_tcpClient disconnect];
}

//心跳发送
- (void)heartBeatAction{
    Byte heartBeatBytes[10];
    heartBeatBytes[0] = 0x01;
    heartBeatBytes[1] = cycleByte;
    [self addCycleByte];
    
    for (int i=2; i<8; i++) {
        heartBeatBytes[i] = 0x00;
    }
    heartBeatBytes[8] = 0x0D;
    heartBeatBytes[9] = 0x0A;
    
    NSData *sendData = [NSData dataWithBytes:heartBeatBytes length:10];
    Boolean state = [_tcpClient isConnected];
    NSLog(@"is connected:%d",state);
    //发送数组
    tempHeartBeatConnect = NO;
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    dispatch_sync(queue, ^{
        CFTimeInterval start = CFAbsoluteTimeGetCurrent();
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        while ((end-start)<REMOTETIMEOUT) {
            
            [heartBeatLock lock];
            if (heartBeatCache.count > 0) {

                tempHeartBeatConnect = YES;
                [heartBeatCache removeObjectAtIndex:0];
                [heartBeatLock unlock];
                break;
            
            }
            
            [heartBeatLock unlock];
            
            end = CFAbsoluteTimeGetCurrent();
        }
    });
    
    if (tempHeartBeatConnect) {
        heartBeatConnected = YES;
    } else {
        heartBeatConnected = NO;
        [_tcpClient disconnect];
    }
    
}

//连接和注册动作
- (NSInteger)registerToServerWithClientName:(NSString *)rClientName withIsPositive:(Boolean)rIsPositive withIsReconnect:(Boolean)rIsReconnect withClientVer:(NSString *)rClientVer withPinCode:(NSString *)rPinCode withHeartBeatSec:(NSInteger)rHeartBeatSec{
    
    NSError *error = nil;//192.168.137.197 101.37.83.8
    if ([self.tcpClient connectToHost:@"101.37.83.8" onPort:10086 error:&error]) {
//        NSLog(@"connect successful");
        Boolean state = [_tcpClient isConnected];
        NSLog(@"is connected :%d",state);
//        if (!state) {
//            NSLog(@"connect failed");
//            return -3;
//        }
        
        //必须添加readDataWithTimeout方法
        [self.tcpClient readDataWithTimeout:-1 tag:0];
        /*
        //打包发送内容
        NSMutableData *sendData = [[NSMutableData alloc] init];
        
//        NSMutableArray<NSData *> *protocalArray = [[NSMutableArray alloc] initWithCapacity:4];
        //发送头
        Byte startByte[4];
        startByte[0] = PROTOCOLHEAD;
        startByte[1] = cycleByte;
        Byte nowCycleByte = startByte[1];
        //累加循环码
        [self addCycleByte];
        startByte[2] = 0x01;    //主指令
        startByte[3] = 0x01;    //子指令
        //打包起始 头、循环码、主指令、子指令
        NSData *startData = [[NSData alloc] initWithBytes:startByte length:4];

        //协议内容及长度
//        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:                     @"HiDevice48",@"ClientName",@"False",@"isPositive",@"False",@"isReconnect",@"1.00",@"ClientVer",@"1234",@"PinCode",@"30",@"HeartBeatSec",nil];
        NSString *isPositiveStr = @"False";
        if (rIsPositive) {
            isPositiveStr = @"Ture";
        }
        
        NSString *isReconnectStr = @"False";
        if (rIsReconnect) {
            isReconnectStr = @"Ture";
        }
        
        NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:                     rClientName,@"ClientName",isPositiveStr,@"isPositive",isReconnectStr,@"isReconnect",rClientVer,@"ClientVer",rPinCode,@"PinCode",[NSString stringWithFormat:@"%d",rHeartBeatSec],@"HeartBeatSec",nil];
        NSString *contentJsonStr = [self dictionaryToJsonString:contentDict];
        //打包内容
        NSData *contentData = [contentJsonStr dataUsingEncoding:NSUTF8StringEncoding];
        
        int tempLen = contentData.length;
        Byte lenbyte[4];
        for (int i=0; i<4; i++) {
            lenbyte[i] = ((Byte *)&tempLen)[i];
        }
        //打包长度
        NSData *lenData = [[NSData alloc] initWithBytes:lenbyte length:4];
        
        //打包结束
        Byte endByte[2] = {0x0D,0x0A};
        NSData *endData = [[NSData alloc] initWithBytes:endByte length:2];
        
        [sendData appendData:startData];
        [sendData appendData:lenData];
        [sendData appendData:contentData];
        [sendData appendData:endData];
        
//        NSInteger lennn =sendData.length;
//        NSLog(@"%d",lennn);
        */
        NSString *isPositiveStr = @"False";
        if (rIsPositive) {
            isPositiveStr = @"Ture";
        }
        
        NSString *isReconnectStr = @"False";
        if (rIsReconnect) {
            isReconnectStr = @"Ture";
        }
        
        NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:                     rClientName,@"ClientName",isPositiveStr,@"isPositive",isReconnectStr,@"isReconnect",rClientVer,@"ClientVer",rPinCode,@"PinCode",[NSString stringWithFormat:@"%d",rHeartBeatSec],@"HeartBeatSec",nil];
        Byte nowCycleByte = cycleByte;
        NSData *sendData = [self packSendDataWithCmd1:0x01 withCmd2:0x01 withContentDict:contentDict withCycleByte:nowCycleByte];
        //累加循环码
        [self addCycleByte];
        tempRequestReturnData = nil;
        //发送数组
        [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
        
        dispatch_sync(queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            while ((end-start)<REMOTETIMEOUT) {
                
                [requestReturnLock lock];
                if (requestReturnCache.count > 0) {
                    for (int i=0; i<requestReturnCache.count; i++) {
                        Byte *tempByte = (Byte *)[requestReturnCache[i] bytes];
                        if ((tempByte[1] == nowCycleByte) && (tempByte[2] == 0x01) && (tempByte[3] == 0x01)) {
                            tempRequestReturnData = [NSData dataWithBytes:&tempByte[8] length:requestReturnCache[i].length-10];
                            [requestReturnCache removeObjectAtIndex:i];
                            break;
                        }
                    }
                    
                    
                    if (tempRequestReturnData == nil) {
                        
                    } else {
                        [requestReturnLock unlock];
                        break;
                    }
                }
                
                [requestReturnLock unlock];
                
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        
        if (tempRequestReturnData == nil) {
            notNeedDisconnectDelegate = true;
            [_tcpClient disconnect];
            return -2;
        } else {
            
            NSString *jsonString = [[NSString alloc] initWithData:tempRequestReturnData encoding:NSUTF8StringEncoding];
            NSDictionary *dict = [self jsonStringToDiction:jsonString];
            int test = [dict[@"Info"] intValue];
            switch (test) {
                case 1:case 3:case 4:{

                    heartBeatInv = rHeartBeatSec;
                    heartBeatConnected = YES;
                    [self performSelectorOnMainThread:@selector(enableHeartBeatTimer) withObject:nil waitUntilDone:NO];
                    receiveNoticeDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveNoticeDataThreadAction) object:nil];
                    [receiveNoticeDataThread start];
                    
                    receiveNeedAnswerDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveNeedAnswerDataThreadAction) object:nil];
                    [receiveNeedAnswerDataThread start];
                    
                    receiveMNeedNoAnswerDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(receiveNotNeedAnswerDataThreadAction) object:nil];
                    [receiveMNeedNoAnswerDataThread start];
                    break;
                }
                default:
                    notNeedDisconnectDelegate = true;
                    [_tcpClient disconnect];
                    break;
            }
            return test;
        }

        
    }
    else{
        NSLog(@"not connected");
        notNeedDisconnectDelegate = true;
        [_tcpClient disconnect];
        return -3;
    }
    
}

#pragma mark - 客户端返回动作
/**返回动作
 */

- (void)responseChangeGroupWithIsSuccess:(Boolean)rIsSuccess withCycleByte:(Byte)rCycleByte{
    NSString *rIsSuccessStr = @"False";
    if (rIsSuccess) {
        rIsSuccessStr = @"True";
    }
    NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:                     rIsSuccessStr,@"Info",nil];
    NSData *sendData = [self packSendDataWithCmd1:0x02 withCmd2:0x01 withContentDict:contentDict withCycleByte:rCycleByte];
    
    //发送数组
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    NSLog(@"send change group back");

    
}
- (void)responseReadParaWithIsSuccess:(Boolean)rIsSuccess withValue:(NSString *)rValue withCycleByte:(Byte)rCycleByte{
    NSString *rIsSuccessStr = @"False";
    if (rIsSuccess) {
        rIsSuccessStr = @"True";
    }
    NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:                     rIsSuccessStr,@"Info",rValue,@"Value",nil];
    NSData *sendData = [self packSendDataWithCmd1:0x02 withCmd2:0x03 withContentDict:contentDict withCycleByte:rCycleByte];
    
    //发送数组
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    NSLog(@"send read data para back");
}

- (void)responseWriteParaWithIsSuccess:(Boolean)rIsSuccess withCycleByte:(Byte)rCycleByte{
    NSString *rIsSuccessStr = @"False";
    if (rIsSuccess) {
        rIsSuccessStr = @"True";
    }
    NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:                     rIsSuccessStr,@"Info",nil];
    NSData *sendData = [self packSendDataWithCmd1:0x02 withCmd2:0x05 withContentDict:contentDict withCycleByte:rCycleByte];
    
    //发送数组
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    NSLog(@"send write data para back");
}

- (void)responseChangeModeWithIsSuccess:(Boolean)rIsSuccess withCycleByte:(Byte)rCycleByte{
    NSString *rIsSuccessStr = @"False";
    if (rIsSuccess) {
        rIsSuccessStr = @"True";
    }
    NSDictionary *contentDict = [NSDictionary dictionaryWithObjectsAndKeys:                     rIsSuccessStr,@"Info",nil];
    NSData *sendData = [self packSendDataWithCmd1:0x02 withCmd2:0x07 withContentDict:contentDict withCycleByte:rCycleByte];
    
    //发送数组
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    NSLog(@"send change mode back");
}
- (void)responseReadOfflineChannelWithChannelData:(NSMutableData *)rChannelData withCycleByte:(Byte)rCycleByte{
    NSData *sendData = [self packSendDataWithCmd1:0x02 withCmd2:0x09 withContentData:rChannelData withCycleByte:rCycleByte];
    //发送数组
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    NSLog(@"send channel data mode back");
}
- (void)responseRecordActionWithIsSuccess:(Byte)rSuccessByte withCycleByte:(Byte)rCycleByte{
    
    NSMutableData *contentData = [NSMutableData dataWithBytes:&rSuccessByte length:1];
    NSData *sendData = [self packSendDataWithCmd1:0x02 withCmd2:11 withContentData:contentData withCycleByte:rCycleByte];
    //发送数组
    [self.tcpClient writeData:sendData withTimeout:-1 tag:0];
    NSLog(@"send record action back");
}

#pragma mark - 打包发送内容
//打包返回的内容
- (NSData *)packSendDataWithCmd1:(Byte)rCmd1 withCmd2:(Byte)rCmd2 withContentDict:(NSDictionary*)rContentDict withCycleByte:(Byte)rCycleByte{
    //打包发送内容
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    //        NSMutableArray<NSData *> *protocalArray = [[NSMutableArray alloc] initWithCapacity:4];
    //发送头
    Byte startByte[4];
    startByte[0] = PROTOCOLHEAD;
    startByte[1] = rCycleByte;
    startByte[2] = rCmd1;    //主指令
    startByte[3] = rCmd2;    //子指令
    //打包起始 头、循环码、主指令、子指令
    NSData *startData = [[NSData alloc] initWithBytes:startByte length:4];
    
    //协议内容及长度
    NSString *contentJsonStr = [self dictionaryToJsonString:rContentDict];
    //打包内容
    NSData *contentData = [contentJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    int tempLen = contentData.length;
    Byte lenbyte[4];
    for (int i=0; i<4; i++) {
        lenbyte[i] = ((Byte *)&tempLen)[i];
    }
    //打包长度
    NSData *lenData = [[NSData alloc] initWithBytes:lenbyte length:4];
    
    //打包结束
    Byte endByte[2] = {0x0D,0x0A};
    NSData *endData = [[NSData alloc] initWithBytes:endByte length:2];
    
    [sendData appendData:startData];
    [sendData appendData:lenData];
    [sendData appendData:contentData];
    [sendData appendData:endData];
    
    return sendData;
    
}

- (NSData *)packSendDataWithCmd1:(Byte)rCmd1 withCmd2:(Byte)rCmd2 withContentData:(NSMutableData*)rContentData withCycleByte:(Byte)rCycleByte{
    //打包发送内容
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    //        NSMutableArray<NSData *> *protocalArray = [[NSMutableArray alloc] initWithCapacity:4];
    //发送头
    Byte startByte[4];
    startByte[0] = PROTOCOLHEAD;
    startByte[1] = rCycleByte;
    startByte[2] = rCmd1;    //主指令
    startByte[3] = rCmd2;    //子指令
    //打包起始 头、循环码、主指令、子指令
    NSData *startData = [[NSData alloc] initWithBytes:startByte length:4];
    
//    //协议内容及长度
//    NSString *contentJsonStr = [self dictionaryToJsonString:rContentDict];
//    //打包内容
//    NSData *contentData = [contentJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    int tempLen = rContentData.length;
    Byte lenbyte[4];
    for (int i=0; i<4; i++) {
        lenbyte[i] = ((Byte *)&tempLen)[i];
    }
    //打包长度
    NSData *lenData = [[NSData alloc] initWithBytes:lenbyte length:4];
    
    //打包结束
    Byte endByte[2] = {0x0D,0x0A};
    NSData *endData = [[NSData alloc] initWithBytes:endByte length:2];
    
    [sendData appendData:startData];
    [sendData appendData:lenData];
    [sendData appendData:rContentData];
    [sendData appendData:endData];
    
    return sendData;
}
//打包主动发送的内容
- (NSData *)packSendBytes:(Byte)rCmd1 withCmd2:(Byte)rCmd2 withContentData:(NSData*)rContentData{
    //打包发送内容
    NSMutableData *sendData = [[NSMutableData alloc] init];
    
    //        NSMutableArray<NSData *> *protocalArray = [[NSMutableArray alloc] initWithCapacity:4];
    //发送头
    Byte startByte[4];
    startByte[0] = PROTOCOLHEAD;
    startByte[1] = cycleByte;
    [self addCycleByte];
    startByte[2] = rCmd1;    //主指令
    startByte[3] = rCmd2;    //子指令
    //打包起始 头、循环码、主指令、子指令
    NSData *startData = [[NSData alloc] initWithBytes:startByte length:4];
    
    //协议内容及长度

    
    int tempLen = rContentData.length;
    Byte lenbyte[4];
    for (int i=0; i<4; i++) {
        lenbyte[i] = ((Byte *)&tempLen)[i];
    }
    //打包长度
    NSData *lenData = [[NSData alloc] initWithBytes:lenbyte length:4];
    
    //打包结束
    Byte endByte[2] = {0x0D,0x0A};
    NSData *endData = [[NSData alloc] initWithBytes:endByte length:2];
    
    [sendData appendData:startData];
    [sendData appendData:lenData];
    [sendData appendData:rContentData];
    [sendData appendData:endData];
    
    return sendData;
}
#pragma mark - 查询是否接收数据
- (void)receiveNoticeDataThreadAction{
    while (1) {
        Byte *tempByte;
        NSInteger tempByteSize;
        Boolean ifReceived = NO;
        [noticeLock lock];

        if (noticeCache.count>0) {
            tempByte = (Byte *)[noticeCache[0] bytes];
            tempByteSize = noticeCache[0].length;
            [noticeCache removeObjectAtIndex:0];
            ifReceived = YES;
        }
        [noticeLock unlock];
        
        if (ifReceived) {
            switch (tempByte[3]) {
                case 1:
                    if ([theDelegate respondsToSelector:@selector(remoteNoticeWhenOppsiteDisconnect)]) {
                        [theDelegate remoteNoticeWhenOppsiteDisconnect];
                    }
                    break;
                case 2:{
                    NSData *tempData = [NSData dataWithBytes:&tempByte[8] length:tempByteSize-10];
                    NSString *jsonString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
                    NSDictionary *dict = [self jsonStringToDiction:jsonString];
                    if ([theDelegate respondsToSelector:@selector(remoteNoticeWhenRematchedWithOppsiteName:)]) {
                        [theDelegate remoteNoticeWhenRematchedWithOppsiteName:dict[@"Info"]];
                    }
                    break;
                }
                case 3:
                    if ([theDelegate respondsToSelector:@selector(remoteNoticeWhenDismatched)]) {
                        [theDelegate remoteNoticeWhenDismatched];
                    }
                    break;
                case 4:{
                    NSData *tempData = [NSData dataWithBytes:&tempByte[8] length:tempByteSize-10];
                    NSString *jsonString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
                    NSDictionary *dict = [self jsonStringToDiction:jsonString];
                    if ([theDelegate respondsToSelector:@selector(remoteNoticeWhenMatchedWithOppsiteName:)]) {
                        [theDelegate remoteNoticeWhenMatchedWithOppsiteName:dict[@"Info"]];
                    }
                    break;
                }
            }
        }

        
        
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
        }
        [NSThread sleepForTimeInterval:0.001f];
    }
}

- (void)receiveNeedAnswerDataThreadAction{
    while (1) {
        Byte *tempByte;
        NSInteger tempByteSize;
        Boolean ifReceived = NO;
        [needAnswerLock lock];
        
        if (needAnswerCache.count>0) {
            tempByte = (Byte *)[needAnswerCache[0] bytes];
            tempByteSize = needAnswerCache[0].length;
            [needAnswerCache removeObjectAtIndex:0];
            ifReceived = YES;
        }
        [needAnswerLock unlock];
        
        if (ifReceived) {
            NSData *tempData = [NSData dataWithBytes:&tempByte[8] length:tempByteSize-10];
            NSString *jsonString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
            NSDictionary *dict = [self jsonStringToDiction:jsonString];
            switch (tempByte[3]) {
                case 0:{

                    if ([theDelegate respondsToSelector:@selector(remoteNeedReturnChangeGroupWithGroupIndex:withCycleByte:)]) {
                        [theDelegate remoteNeedReturnChangeGroupWithGroupIndex:[dict[@"GroupIndex"] intValue] withCycleByte:tempByte[1]];
                    }
                    break;
                }
                case 2:{

                    if ([theDelegate respondsToSelector:@selector(remoteNeedReturnReadParaWithIndex:withSubindex:withArrayIndex:withCycleByte:)]) {
                        [theDelegate remoteNeedReturnReadParaWithIndex:[dict[@"Index"] intValue] withSubindex:[dict[@"Subindex"] intValue] withArrayIndex:[dict[@"Arrayindex"] intValue] withCycleByte:tempByte[1]];
                    }
                    break;
                }
                case 4:{

                    if ([theDelegate respondsToSelector:@selector(remoteNeedReturnWriteParaWithIndex:withSubindex:withArrayIndex:withValue:withCycleByte:)]) {
                        [theDelegate remoteNeedReturnWriteParaWithIndex:[dict[@"Index"] intValue] withSubindex:[dict[@"Subindex"] intValue] withArrayIndex:[dict[@"Arrayindex"] intValue] withValue:dict[@"Value"] withCycleByte:tempByte[1]];
                    }
                    break;
                }
                case 6:{
                    if ([theDelegate respondsToSelector:@selector(remoteNeedReturnChangeModeWithModeIndex:withCycleByte:)]) {
                        [theDelegate remoteNeedReturnChangeModeWithModeIndex:[dict[@"ModeIndex"] intValue] withCycleByte:tempByte[1]];
                    }
                    break;
                }
                case 8:{
                    if ([theDelegate respondsToSelector:@selector(remoteNeedReturnReadOfflineChannelWithChannelIndex:withCycleByte:)]) {
                        [theDelegate remoteNeedReturnReadOfflineChannelWithChannelIndex:[dict[@"ChannelID"] intValue] withCycleByte:tempByte[1]];
                    }
                    break;
                }
                case 10:{

                    if ([theDelegate respondsToSelector:@selector(remoteNeedReturnRecordActionWithCommandByte:withCycleByte:)]) {
                        [theDelegate remoteNeedReturnRecordActionWithCommandByte:tempByte[8] withCycleByte:tempByte[1]];
                    }
                    break;
                }
            }
        }
        
        
        
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
        }
        [NSThread sleepForTimeInterval:0.001f];
    }
}

- (void)receiveNotNeedAnswerDataThreadAction{
    while (1) {
        Byte *tempByte;
        NSInteger tempByteSize;
        Boolean ifReceived = NO;
        [notNeedAnswerLock lock];
        
        if (notNeedAnswerCache.count>0) {
            tempByte = (Byte *)[notNeedAnswerCache[0] bytes];
            tempByteSize = notNeedAnswerCache[0].length;
            [notNeedAnswerCache removeObjectAtIndex:0];
            ifReceived = YES;
        }
        [notNeedAnswerLock unlock];
        
        if (ifReceived) {
            NSData *tempData = [NSData dataWithBytes:&tempByte[8] length:tempByteSize-10];
            NSString *jsonString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
            NSDictionary *dict = [self jsonStringToDiction:jsonString];
            switch (tempByte[3]) {
                case 1:{
                    
                    if ([theDelegate respondsToSelector:@selector(remoteNotNeedAnswerDirectWrite:withSubindex:withArrayIndex:withValue:withCycleByte:)]) {
                        [theDelegate remoteNotNeedAnswerDirectWrite:[dict[@"Index"] intValue] withSubindex:[dict[@"Subindex"] intValue] withArrayIndex:[dict[@"Arrayindex"] intValue] withValue:dict[@"Value"] withCycleByte:tempByte[1]];
                    }
                    break;
                }
            }
        }
        
        
        
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
        }
        [NSThread sleepForTimeInterval:0.001f];
    }
}
#pragma mark - TCP Client  delegate
/** GCDAsyncSocket掉线代理
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"socket disconnect");
    if (heartBeatTimer == nil) {
        
    } else {
        [heartBeatTimer setFireDate:[NSDate distantFuture]];
        [heartBeatTimer invalidate];
        heartBeatTimer = nil;
    }
    [receiveNoticeDataThread cancel];
    [receiveNeedAnswerDataThread cancel];
    if (notNeedDisconnectDelegate) {
        notNeedDisconnectDelegate = NO;
    } else {
        if ([theDelegate respondsToSelector:@selector(socketDisconnect)]) {
            [theDelegate socketDisconnect];
        }
    }

    

}

/** GCDAsyncSocket 的接收线程
 通过调用readDataWithTimeout:-1 tag:0 开启接收线程
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [receiveData appendData:data];
    [self processReceiveData];
    
    NSLog(@"%@",[NSThread currentThread]);

    [self.tcpClient readDataWithTimeout:-1 tag:0];
}


- (void)processReceiveData{
    
    
//    int endLocation = 0;    //od oa 的结束位置
    Boolean startProcess = YES;
    
    while ((startProcess) && (receiveData.length > 9)) {
        
        Byte *recvDataBytes = (Byte *)[receiveData bytes];
        startProcess = NO;
        if (recvDataBytes[0] == 0x01) {
            int *dataLen;
            dataLen = (int *)&recvDataBytes[4];
            if (receiveData.length >= (10 + *dataLen)) {

                if ((recvDataBytes[8+*dataLen] == 0x0D) && (recvDataBytes[8+*dataLen+1] == 0x0A)) {
                    
                    NSData *contentData = [NSData dataWithBytes:recvDataBytes length:(10+*dataLen)];
//                    heartBeatCache = [[NSMutableArray alloc] init];
//                    requestReturnCache = [[NSMutableArray alloc] init];
//                    needAnswerCache = [[NSMutableArray alloc] init];
//                    noticeCache = [[NSMutableArray alloc] init];
                    switch (recvDataBytes[2]) {
                        case 0x00:
                            [heartBeatLock lock];
                            [heartBeatCache addObject:contentData];
                            [heartBeatLock unlock];
                            break;
                            
                        case 0x01:
                            
                            [requestReturnLock lock];
                            
                            [requestReturnCache addObject:contentData];
                            
                            [requestReturnLock unlock];
                            break;
                        case 0x02:
                            [needAnswerLock lock];
                            [needAnswerCache addObject:contentData];
                            [needAnswerLock unlock];
                            break;
                            
                        case 0x05:
                            [noticeLock lock];
                            [noticeCache addObject:contentData];
                            [noticeLock unlock];
                            break;
                        case 0x06:
                            [notNeedAnswerLock lock];
                            [notNeedAnswerCache addObject:contentData];
                            [notNeedAnswerLock unlock];
                            break;
                    }
                    
                    [receiveData replaceBytesInRange:NSMakeRange(0, 8+*dataLen) withBytes:NULL length:0];
                    startProcess = YES;
                } else {
                    [receiveData replaceBytesInRange:NSMakeRange(0, 8+*dataLen) withBytes:NULL length:0];
                    startProcess = YES;
                }
            
            } else
                break;
        
        } else {
            [receiveData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];  // 删除头
            startProcess = YES;
        }
        
    }
    
    /*
    while (startProcess) {
        
        startProcess = NO;
        if (receiveData.length > 8) {
        
        } else
            break;
        
        if (recvDataBytes[0] == 0x01) {
            

            
        }
        
//        if (receiveData.length > 1) {
//
//        } else
//            break;
//
//        for (int i=1; i<receiveData.length; i++) {
//            if ((recvDataBytes[i] == 0x0A) && (recvDataBytes[i-1] == 0x0D)) {
//                startProcess = YES;
//                endLocation = i;
//                break;
//            }
//        }
//
//        if (startProcess) {
//            if (recvDataBytes[0] == 0x01) {
//                NSData *nowData = [NSData dataWithBytes:recvDataBytes length:endLocation+1];
//            }
//
//
//
//            [receiveData replaceBytesInRange:NSMakeRange(0, endLocation) withBytes:NULL length:0];  // 删除内容
//        }
        
        
    }
     */
    
    
}

#pragma mark - 转换等功能函数
//dictionary 转成string
- (NSString *)dictionaryToJsonString:(NSDictionary*)rDict{
    
    NSData *tempData = [NSJSONSerialization dataWithJSONObject:rDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *tempString = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
    
    NSMutableString *resultString = [NSMutableString stringWithString:tempString];
    NSRange range = {0, tempString.length};
    [resultString replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//    NSLog(@"%@",resultString);
    
    NSRange range2 = {0, resultString.length};
    [resultString replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
//    NSLog(@"%@",resultString);
    return resultString;
}
//string 转成dictionary
- (NSDictionary *)jsonStringToDiction:(NSString *)rJsonString{
    NSData *tempData = [rJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableContainers error:nil];
    return tempDict;
}

//循环码累加
- (void)addCycleByte{
    
    if (cycleByte == 0xFF) {
        cycleByte = 0;
    } else
        cycleByte++;
}


@end
