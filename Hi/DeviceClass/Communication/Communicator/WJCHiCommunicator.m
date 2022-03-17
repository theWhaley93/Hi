//
//  WJCHiCommunicator.m
//
//
//  Created by apple on 2018/2/12.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCHiCommunicator.h"
#import "WJCGlobalConstants.h"



@interface WJCHiCommunicator(){
    
/** 类扩展，这里的实例变量只在本文件里使用，不对外开放
 */

    CommReturnState recvState;  //通讯返回状态
    dispatch_queue_t queue ;    //线程队列 实例化的时候创建
    NSMutableData *recvData ;   //接收到的未处理数据，bytes 实例化的时候创建
    NSString *recvDataString;   //处理完后的数据
    
    
    NSLock *commLock;   //通讯用的互斥锁
    
    Byte circleByte;
    Byte cmdByte;
    long long int timeoutTimes;
    
    NSString * lastConnectedIP;
    uint16_t   lastConnectedPort;
}

- (void)addCircleByte;
@end


@implementation WJCHiCommunicator

- (instancetype)init{
    recvData = [[NSMutableData alloc] init];
    queue = dispatch_queue_create("raceiveProcess", DISPATCH_QUEUE_SERIAL);
    circleByte = 0;
    commLock = [[NSLock alloc] init];

    timeoutTimes = 0;
    return self;
}
#pragma mark-socket创建及连接
/**创建和连接socket
 */
//@"192.168.43.20"  8899
- (BOOL)createAndConnectSocketOnIP:(NSString *)IP OnPort:(uint16_t)port{

    dispatch_queue_t testQueue = dispatch_queue_create("recvQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSError *error = nil;
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:testQueue];
    if ([self.clientSocket connectToHost:IP onPort:port error:&error]) {
        NSLog(@"connect successful");
        //必须添加readDataWithTimeout方法
        lastConnectedPort = port;
        lastConnectedIP = IP;
        [self.clientSocket readDataWithTimeout:-1 tag:0];
        return YES;
    }
    else{
        NSLog(@"connect failed");
        return NO;
    }
}
- (BOOL)reconnectSocket{
    NSError *error = nil;
    if ([self.clientSocket connectToHost:lastConnectedIP onPort:lastConnectedPort error:&error]) {
        NSLog(@"reconnect successful");
        //必须添加readDataWithTimeout方法
        [self.clientSocket readDataWithTimeout:-1 tag:0];
        return YES;
    }
    else{
        NSLog(@"reconnect failed");
        return NO;
    }
}

#pragma mark-外面调用的read动作
//读根据WJCOneParameter 读参数 在驱动器参数刷新主界面调用
- (NSString *)readWithPara:(WJCOneParameter *)onePara isArrayEnable:(Boolean) rIsArrEnable{
    NSString *tempS = @"";
    if (onePara.isArray) {
        if (rIsArrEnable) {
            if (onePara.isDataSet) {
                for (int j=0; j<2; j++) {
                    for (int i=0; i<onePara.arrayCount; i++) {
                        NSString *recStr = [self readArrayDataWithIndex:onePara.index withSubindex:j withArrayIndex:i];
                        
                        [onePara setValHexWithSubindex:j withArrayIndex:i val:recStr];
                    }
                }
            } else {
                for (int i=0; i<onePara.arrayCount; i++) {
                    NSString *recStr = [self readArrayDataWithIndex:onePara.index withSubindex:0 withArrayIndex:i];
                    
                    [onePara setValHexWithSubindex:0 withArrayIndex:i val:recStr];
                }
            }
        }
        
    } else {
        int dataSetNum = 1;
        if (onePara.isDataSet) {
            dataSetNum = 2;
        }
        for (int i=0; i<dataSetNum; i++) {
            if (onePara.isString) {
                tempS = [self readStringData:onePara.index subindex:i];
            } else {
                tempS = [self readData:onePara.index subindex:i];
            }
//            if(onePara.index == 153) {
//                nowDataTest = tempS;
//                if (![nowDataTest isEqualToString:lastDataTest]) {
//                    NSString * ttt = lastDataTest;
//                }
//                lastDataTest = nowDataTest;
//            }
            [onePara setValHexWithSubindex:i withArrayIndex:0 val:tempS];
        }

//        [onePara setValHexWithSubindex:0 withArrayIndex:0 val:tempS];
    }
    return tempS;
}
//读根据index subindex arrayindex读参数，外部调用
- (NSString *)readWithPara:(WJCOneParameter *)onePara withindex:(int)rIndex withSubindex:(int)rSubI withArrayIndex:(int)rArrayI{
    NSString *tempS = @"";
    if (onePara.isArray) {
        tempS = [self readArrayDataWithIndex:rIndex withSubindex:rSubI withArrayIndex:rArrayI];
        [onePara setValHexWithSubindex:rSubI withArrayIndex:rArrayI val:tempS];
        
    } else {
        if (onePara.isString) {
            tempS = [self readStringData:rIndex subindex:rSubI];
        } else {
            tempS = [self readData:rIndex subindex:rSubI];
        }

        [onePara setValHexWithSubindex:rSubI withArrayIndex:rArrayI val:tempS];

    }
    return tempS;
}

//读根据index subindex arrayindex写参数，外部调用
- (NSString *)writeWithPara:(WJCOneParameter *)onePara withindex:(int)rIndex withSubindex:(int)rSubI withArrayIndex:(int)rArrayI withValue:(NSString *)rVal{
    NSString *tempS = @"";
    if (onePara.isArray) {
        tempS = [self writeArrayWithIndex:rIndex withSubindex:rSubI withArrayIndex:rArrayI withData:rVal withDataLen:onePara.len];

        
    } else {
        if (onePara.isString) {
            tempS = [self writeStringWithIndex:rIndex withSubindex:rSubI withStringData:rVal];
        } else {
            tempS = [self writeWithIndex:rIndex withSubindex:rSubI withData:rVal withDataLen:onePara.len];
        }
        
    }
    return tempS;
}

- (NSString *)readWithDatasetPara:(WJCOneParameter *) rPara {
    NSString *tempS = @"";
    return tempS;
}

#pragma mark-Hi协议的方法

#pragma mark-读参数方法
/**
 普通参数读取协议
 @param index 索引
 @param subi 子索引
 @return 字符串
 */
- (NSString *)readData:(NSInteger)index subindex:(NSInteger)subi{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    cmdByte = 0x10 ^ circleByte;    //读取0x10
    
    Byte b[] = {2,16,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[1] = cmdByte;
    uint16ToAscii(index, &b[2]);
    byteToAscii(subi, &b[6]);
    byteToAscii(makeCheckCode(b), &b[9]);
    
    NSData *data  = [NSData dataWithBytes:b length:11];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
//    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
//        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<READTIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                //判断校验码
                                if (checkBcc(&byte[0])) {
                                    //校验接收失败
                                    self->recvState = COMMRTN_CHKERR;

                                    break;
                                } else {
                                    //校验接收成功
                                    
                                    BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                    for (int i = 0; i < len-3; i++) {
                                        if (byte[i] == 0x03) {
                                            recEndByte = YES;
                                            break;
                                        }
                                    }
                                    
                                    if (recEndByte) {   //判断是否有多个03结束位
                                        self->recvState = COMMRTN_CHKERR;

                                        break;
                                    }
                                    
                                    Byte tempB[8];// = {0,0,0,0,0,0,0,0};
                                    NSInteger tempL = (len-5) / 2;
                                    for (int i = 0; i<tempL ; i++) {
                                        tempB[i] = asciiToByte(&byte[2*i+2]);
                                    }
                                    
                                    for (NSInteger i = tempL; i>0; i--) {
                                        self->recvDataString = [self->recvDataString stringByAppendingString:[NSString stringWithFormat:@"%02X",tempB[i-1]]];
                                    }
                                    self->recvState = COMMRTN_SUC;
                                    
                                    break;
                                    
                                }
                                }
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;

                                break;
                            }
                        }
                        
                    }
                }

                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    

    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
//    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    NSString *resultStr = self->recvDataString;
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
//            NSLog(@"recv_ok");
            return resultStr;

            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
//            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }

    }
    

}


/**
 读取字符串协议
 @param rIndex 索引
 @param rSubi 子索引
 @return 返回字符串
 */
- (NSString*)readStringData:(NSInteger)rIndex subindex:(NSInteger)rSubi{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    cmdByte = 0xC0 ^ circleByte;
    
    Byte b[] = {2,0,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[1] = cmdByte;
    uint16ToAscii(rIndex, &b[2]);
    byteToAscii(rSubi, &b[6]);
    byteToAscii(makeCheckCode(b), &b[9]);
    
    NSData *data  = [NSData dataWithBytes:b length:11];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        NSDate *start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3) 
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;

                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;

                                            break;
                                        }
                                        Byte strLen = asciiToByte(&byte[2]);
                                        
                                        if (strLen>0) {
                                            
                                            for (int i = 0; i<strLen ; i++) {
                                                //                                        bStr = [NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])];
                                                self->recvDataString = [self->recvDataString stringByAppendingString:[NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])]];
                                            }
                                        } else {
                                            
                                        }
                                        //                                Byte tempB[8];// = {0,0,0,0,0,0,0,0};
                                        //                                NSInteger tempL = (len-5) / 2;
                                        //                                for (int i = 0; i<tempL ; i++) {
                                        //                                    tempB[i] = asciiToByte(&byte[2*i+2]);
                                        //                                }
                                        //
                                        //                                for (NSInteger i = tempL; i>0; i--) {
                                        //                                    self->recvDataString = [self->recvDataString stringByAppendingString:[NSString stringWithFormat:@"%02X",tempB[i-1]]];
                                        //                                }
                                        self->recvState = COMMRTN_SUC;

                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;

                                break;
                            }
                        }
                        
                    }
                }

                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }

    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
//    NSLog(@"%f",[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
//            NSLog(@"recv_ok--%@",self->recvDataString);
            return self->recvDataString;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }

    
}


/**
 读矩阵参数

 @param rIndex 索引
 @param rSubi 子索引
 @param rArrayI 矩阵索引
 @return 返回值
 */
- (NSString *)readArrayDataWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withArrayIndex:(NSInteger)rArrayI{
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    cmdByte = 0x90 ^ circleByte;    //读取0x10
    
    Byte b[] = {2,16,0,0,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[1] = cmdByte;
    uint16ToAscii(rIndex, &b[2]);
    byteToAscii(rSubi, &b[6]);
    byteToAscii(rArrayI, &b[8]);
    byteToAscii(makeCheckCode(b), &b[11]);
    
    NSData *data  = [NSData dataWithBytes:b length:13];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空

        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        NSDate *start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;

                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;

                                            break;
                                        }
                                        
                                        Byte tempB[8];// = {0,0,0,0,0,0,0,0};
                                        NSInteger tempL = (len-5) / 2;
                                        for (int i = 0; i<tempL ; i++) {
                                            tempB[i] = asciiToByte(&byte[2*i+2]);
                                        }
                                        
                                        for (NSInteger i = tempL; i>0; i--) {
                                            self->recvDataString = [self->recvDataString stringByAppendingString:[NSString stringWithFormat:@"%02X",tempB[i-1]]];
                                        }
                                        self->recvState = COMMRTN_SUC;

                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;

                                break;
                            }
                        }
                        
                    }
                }

                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    

    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
//    NSLog(@"%f",[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return self->recvDataString;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
//            NSLog(@"timeout--%@",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
}
#pragma mark-写参数方法
/**
 写方法
 @param rIndex 索引
 @param rSubi 子索引
 @param rData 写入值，字符串
 @param rDataLen 参数长度
 @return 返回通讯结果
 */
- (NSString *)writeWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withData:(NSString *)rData withDataLen:(int)rDataLen{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    
    [commLock lock];

    [self addCircleByte];
    
    cmdByte = 0x20 | circleByte;    //读取0x10

    int sendLen = 11 + rDataLen*2;
    
    Byte b[sendLen];//= {2,0,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[0] = 0x02;
    b[1] = cmdByte;
    uint16ToAscii(rIndex, &b[2]);
    byteToAscii(rSubi, &b[6]);
    b[sendLen-3] = 0x03;
    [self hexsToAscii:[self changeToLittleEnd:rData] withB:&b[8]];
    byteToAscii(makeCheckCode(b), &b[sendLen-2]);
    
    NSData *data  = [NSData dataWithBytes:b length:sendLen];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;

            
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //开始时间
    NSDate *start2 = [NSDate date];
    //循环三次
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        

        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<WRITETIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if ( len==3 ) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            
                            
                            if ((byte[2] & 0xF0) == 0xF0) {

                                if (byte[2] == 0xF6) {
                                    self->recvState = COMMRTN_INVBUSY;
                                    break;
                                } else {
                                    self->recvState = COMMRTN_OTHERFAIL;
                                    break;
                                }
                                
                            } else if (byte[2] == 0x06){
                                
                                self->recvState = COMMRTN_SUC;

                                break;
                                
                            }
                        } 
                        
                    }
                }

                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    

    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    NSLog(@"%f",[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
//            NSLog(@"timeout--%@",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }

    
}

- (void)writeDirWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withData:(NSString *)rData withDataLen:(int)rDataLen{
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    
    [commLock lock];
    
    [self addCircleByte];
    
    cmdByte = 0xB0 ^ circleByte;    //读取0x10
    
    int sendLen = 11 + rDataLen*2;
    
    Byte b[sendLen];//= {2,0,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[0] = 0x02;
    b[1] = cmdByte;
    uint16ToAscii(rIndex, &b[2]);
    byteToAscii(rSubi, &b[6]);
    b[sendLen-3] = 0x03;
    [self hexsToAscii:[self changeToLittleEnd:rData] withB:&b[8]];
    byteToAscii(makeCheckCode(b), &b[sendLen-2]);
    
    NSData *data  = [NSData dataWithBytes:b length:sendLen];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    //发送数组
    [self.clientSocket writeData:data withTimeout:-1 tag:1];
    
    [commLock unlock];
    
    
}
/**
 读字符串参数
 @param rIndex 索引
 @param rSubi 子索引
 @param rStringData 内容
 @return 返回结果
 */
- (NSString *)writeStringWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withStringData:(NSString *)rStringData{
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    cmdByte = 0xD0 ^ circleByte;    //读取0x10
    [self addCircleByte];
    
    int stringDataLen = [rStringData length];
    int sendLen = 11 + stringDataLen*2 + 2;
    
    Byte b[sendLen];//= {2,0,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[0] = 0x02;
    b[1] = cmdByte;
    uint16ToAscii(rIndex, &b[2]);
    byteToAscii(rSubi, &b[6]);
    uint16ToAscii(stringDataLen, &b[8]);
    
    b[sendLen-3] = 0x03;
    [self stringToAscii:rStringData withB:&b[10]];
    byteToAscii(makeCheckCode(b), &b[sendLen-2]);
    
    NSData *data  = [NSData dataWithBytes:b length:sendLen];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //开始时间
    NSDate *start2 = [NSDate date];
    //循环三次
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        

        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if ( len==3 ) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if ((byte[2] & 0xF0) == 0xF0) {

                                if (byte[2] == 0xF6) {
                                    self->recvState = COMMRTN_INVBUSY;
                                    break;
                                } else {
                                    self->recvState = COMMRTN_OTHERFAIL;
                                    break;
                                }
                                
                            } else if (byte[2] == 0x06){

                                self->recvState = COMMRTN_SUC;
                                break;
                                
                            }
                        }
                        
                    }
                }
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    

    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    NSLog(@"%f",[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
//            NSLog(@"timeout--%@",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }

}

- (NSString *)writeArrayWithIndex:(NSInteger)rIndex withSubindex:(NSInteger)rSubi withArrayIndex:(NSInteger)rArrayI withData:(NSString *)rData withDataLen:(int)rDataLen{
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    
    [commLock lock];
    
    [self addCircleByte];
    
    cmdByte = 0xA0 ^ circleByte;    //读取0x10
    
    int sendLen = 13 + rDataLen*2;
    
    Byte b[sendLen];//= {2,0,0,0,0,0,0,0,3,0,0};//{2,21,48,52,48,48,48,48,3,51,67}
    b[0] = 0x02;
    b[1] = cmdByte;
    uint16ToAscii(rIndex, &b[2]);
    byteToAscii(rSubi, &b[6]);
    byteToAscii(rArrayI, &b[8]);
    b[sendLen-3] = 0x03;
    [self hexsToAscii:[self changeToLittleEnd:rData] withB:&b[10]];
    byteToAscii(makeCheckCode(b), &b[sendLen-2]);
    
    NSData *data  = [NSData dataWithBytes:b length:sendLen];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //开始时间
    NSDate *start2 = [NSDate date];
    //循环三次
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        

        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if ( len==3 ) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if ((byte[2] & 0xF0) == 0xF0) {
                                
                                if (byte[2] == 0xF6) {

                                    self->recvState = COMMRTN_INVBUSY;
                                    break;
                                } else {
                                    self->recvState = COMMRTN_OTHERFAIL;
                                    break;
                                }
                                
                            } else if (byte[2] == 0x06){

                                self->recvState = COMMRTN_SUC;
                                break;
                                
                            }
                        }
                        
                    }
                }

                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    

    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    NSLog(@"%f",[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            NSLog(@"timeout--%@",[NSThread currentThread]);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
}
#pragma mark-record  读组信息+读描述，更新参数文件时用
/**
 读组信息+读描述，更新参数文件时用
 */
//读参数索引与描述索引对应的关系

- (NSString *)readDescIndexWithDescNumber:(uint16_t)rSerialNum withSubindex:(Byte)rSubind paraIndex:(int *)rPParaInd descIndex:(int *)rPDescInd{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    cmdByte = 0x80 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = 0x33;
    uint16ToAscii(rSerialNum, &b[3]);
    byteToAscii(rSubind, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        *rPParaInd = asciiToUint16(&byte[3]);
                                        *rPDescInd = asciiToUint16(&byte[7]);
    //                                    Byte tempB[8];// = {0,0,0,0,0,0,0,0};
    //                                    NSInteger tempL = (len-5) / 2;
    //                                    for (int i = 0; i<tempL ; i++) {
    //                                        tempB[i] = asciiToByte(&byte[2*i+2]);
    //                                    }
    //
    //                                    for (NSInteger i = tempL; i>0; i--) {
    //                                        self->recvDataString = [self->recvDataString stringByAppendingString:[NSString stringWithFormat:@"%02X",tempB[i-1]]];
    //                                    }
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}
//读某个参数描述的个数
- (NSString *)readDescCountWithDescIndex:(uint16_t)rDescIndex descCount:(int *)rDescCnt{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    cmdByte = 0x80 ^ circleByte;
    
    Byte b[10] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = 0x35;
    uint16ToAscii(rDescIndex, &b[3]);
    b[7] = 0x03;
    byteToAscii(makeCheckCode(b), &b[8]);
    
    NSData *data  = [NSData dataWithBytes:b length:10];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        *rDescCnt = asciiToUint16(&byte[3]);

                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//根据desctab索引 读单条描述

- (NSString *)readOneDescWithDescTabIndex:(uint16_t)rDescTabInd withDescTabSubindex:(Byte)rDescTabSubi descTabVal:(int16_t *) rPDeecTabV descTabString:(NSString * *)rPDescTabStr{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x80;       //功能码
    Byte subCmd1 = 0x34;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rDescTabInd, &b[3]);
    byteToAscii(rDescTabSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        *rPDeecTabV = asciiToUint16(&byte[3]);
                                        
                                        int strLen = (len-10) / 2;
                                        NSString *tempStr = @"";
                                        if (strLen>0) {
                                            
                                            for (int i = 0; i<strLen ; i++) {
                                                //                                        bStr = [NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])];
                                                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%c",asciiToByte(&byte[7+i*2])]];
                                            }
                                        } else {
                                            
                                        }
                                        *rPDescTabStr = tempStr;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读位域描述的位和对应描述索引的数组
- (NSString *)readBitFieldTabsWithBitFieldIndex:(uint16_t)rBitFieldIndex bitFieldTabs:(WJCDescBitFieldTabs **)rPBitFieldTabs{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x80;       //功能码
    Byte subCmd1 = 0x38;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[10] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rBitFieldIndex, &b[3]);
    b[7] = 0x03;
    byteToAscii(makeCheckCode(b), &b[8]);
    
    NSData *data  = [NSData dataWithBytes:b length:10];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
//                                        *rPDeecTabV = asciiToUint16(&byte[3]);
                                        
                                        NSInteger bitFieldLen = (len-6) / 8;
                                        WJCDescBitFieldTabs *tempTabs = [[WJCDescBitFieldTabs alloc] init];
                                        tempTabs.items = [[NSMutableArray alloc] initWithCapacity:bitFieldLen];
                                        for (int i=0; i<bitFieldLen; i++) {
                                            WJCDescBitField *tempItem = [[WJCDescBitField alloc] init];
                                            tempItem->len = asciiToUint16(&byte[3+8*i]);
                                            tempItem->index = asciiToUint16(&byte[7+8*i]);
                                            [tempTabs.items addObject:tempItem];
                                        }
                                        *rPBitFieldTabs = tempTabs;
//                                        NSString *tempStr = @"";
//                                        if (strLen>0) {
//
//                                            for (int i = 0; i<strLen ; i++) {
//                                                //                                        bStr = [NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])];
//                                                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%c",asciiToByte(&byte[7+i*2])]];
//                                            }
//                                        } else {
//
//                                        }
//                                        *rPDescTabStr = tempStr;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读组内所有参数索引号
- (NSString *)readGroupContentWithUserLevel:(Byte)rUserLevel withGroupIndex:(Byte)rGroupInd groupContent:(NSMutableArray **)rPGroupContent{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x80;       //功能码
    Byte subCmd1 = 0x30;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[9] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    switch (rUserLevel) {
        case 0:
            b[3] = 0x30;    //  读高级
            break;
        case 1:
            b[3] = 0x31;    //  读中级
            break;
        case 2:
            b[3] = 0x32;    //  读低级
            break;
        default:
            b[3] = 0x30;    //  读高级
            break;
    }
    byteToAscii(rGroupInd, &b[4]);
    b[6] = 0x03;
    byteToAscii(makeCheckCode(b), &b[7]);
    
    NSData *data  = [NSData dataWithBytes:b length:9];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        
                                        Byte groupI = asciiToByte(&byte[4]);
                                        Byte groupL = asciiToByte(&byte[6]);
                                        NSInteger groupContCnt = (len - 11) / 4;
                                        NSMutableArray *tempCont = [[NSMutableArray alloc] initWithCapacity:groupL];
                                        for (int i=0; i<groupL; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithInteger:asciiToUint16(&byte[8+4*i])];
                                            [tempCont addObject:tempNum];
                                        }
                                        *rPGroupContent = tempCont;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}


//读组全称
- (NSString *)readGroupFullNameWithUserLevel:(Byte)rUserLevel withGroupIndex:(Byte)rGroupInd groupFullName:(NSString **)rPFullName{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x80;       //功能码
    Byte subCmd1 = 0x31;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[9] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    switch (rUserLevel) {
        case 0:
            b[3] = 0x30;    //  读高级
            break;
        case 1:
            b[3] = 0x31;    //  读中级
            break;
        case 2:
            b[3] = 0x32;    //  读低级
            break;
        default:
            b[3] = 0x30;    //  读高级
            break;
    }
    byteToAscii(rGroupInd, &b[4]);
    b[6] = 0x03;
    byteToAscii(makeCheckCode(b), &b[7]);
    
    NSData *data  = [NSData dataWithBytes:b length:9];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        
                                        Byte groupI = asciiToByte(&byte[4]);
                                        NSInteger strLen = (len - 9) / 2;
                                        NSString *tempStr = @"";
                                        if (strLen>0) {
                                            
                                            for (int i = 0; i<strLen ; i++) {
                                                //                                        bStr = [NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])];
                                                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%c",asciiToByte(&byte[6+i*2])]];
                                            }
                                        } else {
                                            
                                        }
                                        *rPFullName = tempStr;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读组简称
- (NSString *)readGroupShortNameWithUserLevel:(Byte)rUserLevel withGroupIndex:(Byte)rGroupInd groupShortName:(NSString **)rPShortName{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x80;       //功能码
    Byte subCmd1 = 0x32;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[9] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    switch (rUserLevel) {
        case 0:
            b[3] = 0x30;    //  读高级
            break;
        case 1:
            b[3] = 0x31;    //  读中级
            break;
        case 2:
            b[3] = 0x32;    //  读低级
            break;
        default:
            b[3] = 0x30;    //  读高级
            break;
    }
    byteToAscii(rGroupInd, &b[4]);
    b[6] = 0x03;
    byteToAscii(makeCheckCode(b), &b[7]);
    
    NSData *data  = [NSData dataWithBytes:b length:9];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >3) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        
                                        Byte groupI = asciiToByte(&byte[4]);
                                        NSInteger strLen = (len - 9) / 2;
                                        NSString *tempStr = @"";
                                        if (strLen>0) {
                                            
                                            for (int i = 0; i<strLen ; i++) {
                                                //                                        bStr = [NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])];
                                                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%c",asciiToByte(&byte[6+i*2])]];
                                            }
                                        } else {
                                            
                                        }
                                        *rPShortName = tempStr;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读最大值
- (NSString *)readParaMaxWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi maxData:(NSMutableArray **)rPMaxData{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x60;       //功能码
    Byte subCmd1 = 0x31;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rIndex, &b[3]);
    byteToAscii(rSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >5) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        
                                        int dataLen = (len - 6) / 2;
                                        NSMutableArray *tempData = [[NSMutableArray alloc] initWithCapacity:8];
                                        for (int i =0; i<dataLen; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithInt:asciiToByte(&byte[3+2*i])];
                                            [tempData addObject:tempNum];
                                        }
                                        for (int i=dataLen; i<8; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithChar:0];
                                            [tempData addObject:tempNum];
                                        }
                                        *rPMaxData = tempData;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读最小值
- (NSString *)readParaMinWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi minData:(NSMutableArray **)rPMinData{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x60;       //功能码
    Byte subCmd1 = 0x32;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rIndex, &b[3]);
    byteToAscii(rSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >5) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        
                                        int dataLen = (len - 6) / 2;
                                        NSMutableArray *tempData = [[NSMutableArray alloc] initWithCapacity:8];
                                        for (int i =0; i<dataLen; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithInt:asciiToByte(&byte[3+2*i])];
                                            [tempData addObject:tempNum];
                                        }
                                        for (int i=dataLen; i<8; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithChar:0];
                                            [tempData addObject:tempNum];
                                        }
                                        *rPMinData = tempData;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读默认值
- (NSString *)readParaDefaultWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi defaultData:(NSMutableArray **)rPDefaultData{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x60;       //功能码
    Byte subCmd1 = 0x34;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rIndex, &b[3]);
    byteToAscii(rSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >5) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        
                                        int dataLen = (len - 6) / 2;
                                        NSMutableArray *tempData = [[NSMutableArray alloc] initWithCapacity:8];
                                        for (int i =0; i<dataLen; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithInt:asciiToByte(&byte[3+2*i])];
                                            [tempData addObject:tempNum];
                                        }
                                        for (int i=dataLen; i<8; i++) {
                                            NSNumber *tempNum = [NSNumber numberWithChar:0];
                                            [tempData addObject:tempNum];
                                        }
                                        *rPDefaultData = tempData;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读参数描述
- (NSString *)readParaDescWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi descbContent:(NSString **)rPDescb{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x60;       //功能码
    Byte subCmd1 = 0x33;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rIndex, &b[3]);
    byteToAscii(rSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >5) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        NSInteger strLen = (len - 6) / 2;
                                        NSString *tempStr = @"";
                                        if (strLen>0) {
                                            
                                            for (int i = 0; i<strLen ; i++) {
                                                //                                        bStr = [NSString stringWithFormat:@"%c",asciiToByte(&byte[4+i*2])];
                                                tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%c",asciiToByte(&byte[3+i*2])]];
                                            }
                                        } else {
                                            
                                        }
                                        *rPDescb = tempStr;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读矩阵参数宽度和长度
- (NSString *)readArrayParaInfoWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi arrayWidth:(uint16_t *)rPWidth arrayLength:(uint16_t *)rPLength{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x60;       //功能码
    Byte subCmd1 = 0x35;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rIndex, &b[3]);
    byteToAscii(rSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >5) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        uint16_t tempWid = asciiToUint16(&byte[3]);
                                        uint16_t tempLen = asciiToUint16(&byte[7]);
                                        *rPWidth = tempWid;
                                        *rPLength = tempLen;
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}

//读参数属性
- (NSString *)readParaAttributeWithIndex:(uint16_t)rIndex withSubindex:(Byte)rSubi attrStruct:(WJCAddrStruct *)rPAttrStuct{
    
    //生成要发送的数组
    //    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
    //    NSString *tes = @"0xf";
    //    NSInteger d =  [tes intValue];
    [commLock lock];
    [self addCircleByte];
    Byte cmd1 = 0x60;       //功能码
    Byte subCmd1 = 0x30;    //子功能码
    cmdByte = cmd1 ^ circleByte;
    
    Byte b[12] = {0};
    b[0] = 0x02;
    b[1] = cmdByte;
    b[2] = subCmd1;
    uint16ToAscii(rIndex, &b[3]);
    byteToAscii(rSubi, &b[7]);
    b[9] = 0x03;
    byteToAscii(makeCheckCode(b), &b[10]);
    
    NSData *data  = [NSData dataWithBytes:b length:12];
    //    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
    //    NSData *data  = (NSData *)mutableData;
    
    NSInteger cycleTimes = 0;
    self->recvState = COMMRTN_TIMEOUT;
    //    NSDate *start2 = nil;
    while (!((cycleTimes >5) || (recvState == COMMRTN_SUC))) {
        //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
        
        //    self->startLen = (self->recvData).length;
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
        self->recvDataString = @"";
        
        //发送数组
        [self.clientSocket writeData:data withTimeout:-1 tag:1];
        
        //开始时间
        //        start2 = [NSDate date];
        
        //开启接受数据的处理线程
        
        dispatch_sync(self->queue, ^{
            CFTimeInterval start = CFAbsoluteTimeGetCurrent();
            CFTimeInterval end = CFAbsoluteTimeGetCurrent();
            //判断是否超时
            while ((end-start)<TIMEOUT) {
                //互斥锁
                @synchronized(self)
                {
                    Byte *byte = (Byte*)[self->recvData bytes];
                    NSInteger len = [self->recvData length];
                    if (len>0) {
                        if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                            if (len>3)
                            {
                                if (byte[len-3] == 0x03){
                                    //判断校验码
                                    if (checkBcc(&byte[0])) {
                                        //校验接收失败
                                        self->recvState = COMMRTN_CHKERR;
                                        
                                        break;
                                    } else {
                                        //校验接收成功
                                        
                                        BOOL recEndByte = NO;   //用于判断是否同时接收到了多条数据
                                        for (int i = 0; i < len-3; i++) {
                                            if (byte[i] == 0x03) {
                                                recEndByte = YES;
                                                break;
                                            }
                                        }
                                        
                                        if (recEndByte) {   //判断是否有多个03结束位
                                            self->recvState = COMMRTN_CHKERR;
                                            
                                            break;
                                        }
                                        
                                        int dataLen = (len - 6) / 2;
                                        
                                        WJCAddrStruct tempAttrD;
                                        tempAttrD.attribute = asciiToUint32(&byte[3]);
                                        tempAttrD.dataType = asciiToByte(&byte[11]);
                                        tempAttrD.res1 = asciiToByte(&byte[13]);
                                        tempAttrD.vDiv = asciiToUint16(&byte[15]);
                                        tempAttrD.vMul = asciiToUint16(&byte[19]);
                                        
                                        *rPAttrStuct = tempAttrD;
                                        
                                        self->recvState = COMMRTN_SUC;
                                        
                                        break;
                                        
                                    }
                                }
                                
                            } else if ((byte[len-1] & 0xF0)== 0xF0) {   //判断是否返回错误码
                                //接收返回错误
                                self->recvState = COMMRTN_OTHERFAIL;
                                
                                break;
                            }
                        }
                        
                    }
                }
                
                //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
                //当前时间
                end = CFAbsoluteTimeGetCurrent();
            }
        });
        cycleTimes += 1;
    }
    
    
    
    //处理的结束时间，打印时间间隔
    NSDate *end2 = [NSDate date];
    //    NSLog(@"index:%d read time:%f",index,[end2 timeIntervalSinceDate:start2]);
    
    [commLock unlock];
    //返回结果
    switch (self->recvState) {
        case NONE:{
            NSLog(@"recv_err");
            return COMM_NONE;
            break;
        }
        case COMMRTN_SUC:{
            //            NSLog(@"recv_ok");
            return COMM_SUC;
            
            break;
        }
        case COMMRTN_INVBUSY:{
            
            return COMM_INVBUSY;
            break;
        }
        case COMMRTN_OTHERFAIL:{
            
            return COMM_OTHERFAIL;
            break;
        }
        case COMMRTN_TIMEOUT:{
            //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
            NSLog(@"timeout--%lld",timeoutTimes++);
            return COMM_TIMEOUT;
            
            break;
        }
        case COMMRTN_CHKERR:{
            
            return COMM_CHKERR;
            break;
        }
            
    }
    
    
}


#pragma mark-record 模式开启、关闭、record开启心跳
//record开启心跳
- (void)recordHeartBeat{
    Byte sendByte = 0x07;
    NSLog(@"send 0x07");
    NSData *sendData = [NSData dataWithBytes:&sendByte length:1];
    //发送数组
    [self.clientSocket writeData:sendData withTimeout:-1 tag:1];
}

//record模式开启和关闭
- (NSString *)recordModeOn{
    NSString *resultString = [self writeWithIndex:39 withSubindex:0 withData:@"0004" withDataLen:2];
    [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
    [self->recvData setLength:0];
    return resultString;
}
- (NSString *)recordModeOff{
    return [self writeWithIndex:39 withSubindex:0 withData:@"0002" withDataLen:2];
}

//record曲线采集
- (NSString *)readRecordChannnelDatas{
    return @"";
}

- (NSMutableData *)readRemoteRecordChannelDatas{
    NSMutableData *data = nil;
    [commLock lock];
    if (recvData.length>0) {
        data = [NSMutableData dataWithData:recvData];
        [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
        [self->recvData setLength:0];
    }

    [commLock unlock];
    return data;
}

#pragma mark-读离线通道
- (NSString *)readOfflineChannelWithChannelIndex:(Byte)rChannelI pDataByte:(NSMutableData * *)rPData{
//生成要发送的数组
//    NSString *indexStr = [NSString stringWithFormat:@"%04X",index];
//    NSString *tes = @"0xf";
//    NSInteger d =  [tes intValue];
[commLock lock];
[self addCircleByte];
cmdByte = 0x50 ^ circleByte;

Byte b[] = {2,0,0,3,0,0};
b[1] = cmdByte;
b[2] = [self hexToAscii:rChannelI];
byteToAscii(makeCheckCode(b), &b[4]);

NSData *data  = [NSData dataWithBytes:b length:6];
//    NSMutableData *mutableData = [NSMutableData dataWithBytes:b length:11];
//    NSData *data  = (NSData *)mutableData;

//NSInteger cycleTimes = 0;
self->recvState = COMMRTN_TIMEOUT;

//while (!((cycleTimes >1) || (recvState == COMMRTN_SUC)))

    //准备数据接收，标志位置位；接受缓存清空;返回字符串清空
    
    //    self->startLen = (self->recvData).length;
    [self->recvData resetBytesInRange:NSMakeRange(0, (self->recvData).length)];
    [self->recvData setLength:0];
    self->recvDataString = @"";
    
    //发送数组
    [self.clientSocket writeData:data withTimeout:-1 tag:1];
    
    //开始时间
    NSDate *start2 = [NSDate date];
    
    //开启接受数据的处理线程
    
    dispatch_sync(self->queue, ^{
        CFTimeInterval start = CFAbsoluteTimeGetCurrent();
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        //判断是否超时
        while ((end-start)<OFFLINECHANNELTIMEOUT) {
            //互斥锁
            @synchronized(self)
            {
                Byte *byte = (Byte*)[self->recvData bytes];
                NSInteger len = [self->recvData length];
                if (len>0) {
                    if ((byte[0] == 0x02) && (byte[1]==cmdByte)) {
                        if ((len == 3) && ((byte[len-1] & 0xF0)== 0xF0)) {   //判断是否返回错误码
                            //接收返回错误
                            self->recvState = COMMRTN_OTHERFAIL;
                            
                            break;
                        }
                        if (len>7) {
                            uint16_t dataLen = asciiToUint16(&byte[3]);
                            if (len == (dataLen + 9)) {
                                if (checkOfflineChannelBcc(&byte[7],dataLen+2)) {
                                    self->recvState = COMMRTN_SUC;
                                    [*rPData appendBytes:&byte[7] length:dataLen];
                             
                                    break;
                                } else {
                                    self->recvState = COMMRTN_CHKERR;
                                 
                                    break;
                                }

                            }
                        }

                    }
                    
                }
            }
    
            //            NSLog(@"%@",[NSThread currentThread]);    //打印当前线程
            //当前时间
            end = CFAbsoluteTimeGetCurrent();
        }
    });
//    cycleTimes += 1;




//处理的结束时间，打印时间间隔
NSDate *end2 = [NSDate date];
    NSLog(@"%f",[end2 timeIntervalSinceDate:start2]);

[commLock unlock];
//返回结果
switch (self->recvState) {
    case NONE:{
        NSLog(@"recv_err");
        return COMM_NONE;
        break;
    }
    case COMMRTN_SUC:{
        //            NSLog(@"recv_ok");
        return COMM_SUC;
        
        break;
    }
    case COMMRTN_INVBUSY:{
        
        return COMM_INVBUSY;
        break;
    }
    case COMMRTN_OTHERFAIL:{
        
        return COMM_OTHERFAIL;
        break;
    }
    case COMMRTN_TIMEOUT:{
        //            NSLog(@"timeout--%@--timeout",[NSThread currentThread]);
        NSLog(@"timeout--%lld",timeoutTimes++);
        return COMM_TIMEOUT;
        
        break;
    }
    case COMMRTN_CHKERR:{
        
        return COMM_CHKERR;
        break;
    }
        
}


}

#pragma mark-其它方法
- (void)addCircleByte{
    circleByte++;
    if (circleByte == 0x10) {
        circleByte = 0;
    }
}

/* 把数据改成小端在前方式  如00 32—>32 00
 */
- (NSString *)changeToLittleEnd:(NSString *)data{
    int len = [data length] / 2;
    NSString *resultStr = @"";
    for (int i=len-1; i>=0; i--) {
        NSRange range = NSMakeRange(2*i, 2);
        resultStr = [resultStr stringByAppendingString:[data substringWithRange:range]];
    }
    return resultStr;
}

- (Byte)hexToAscii:(Byte)rData{
    Byte resultB = 0;
    if ((rData>=0) && (rData<=9)) {
        resultB = rData + 0x30;
    }
    if (rData>=10) {
        resultB = rData + 0x41 - 10;
    }
    return resultB;
}

/*Hi协议  把hex转成ascii
 */
- (void)hexsToAscii:(NSString *)rHexs withB:(Byte *)rByte{
    int len = [rHexs length] ;
    for (int i=0; i<len; i++) {
        NSRange rang = NSMakeRange(i, 1);
        NSString *tempDS = [rHexs substringWithRange:rang];
        Byte tempB = strtoul([tempDS UTF8String], 0, 16);
        
        rByte[i] = [self hexToAscii:tempB];
    }
}

/*Hi协议  把string转成ascii
 */
- (void)stringToAscii:(NSString *)rStr withB:(Byte *)rByte{
    int len = [rStr length] ;
    NSString *temAsciiStr = @"";
    for (int i=0; i<len; i++) {
        NSRange rang = NSMakeRange(i, 1);
        char *tempC = [[rStr substringWithRange:rang] UTF8String];
        temAsciiStr = [temAsciiStr stringByAppendingString:[NSString stringWithFormat:@"%02X",tempC[0]]];
        
        
    }
    int len2 = [temAsciiStr length] ;
    for (int i=0; i<len2; i++) {
        NSRange rang = NSMakeRange(i, 1);
        NSString *tempDS = [temAsciiStr substringWithRange:rang];
        Byte tempB = strtoul([tempDS UTF8String], 0, 16);
        
        rByte[i] = [self hexToAscii:tempB];
    }
}

#pragma mark-Socket接收线程
/** GCDAsyncSocket 的接收线程
 通过调用readDataWithTimeout:-1 tag:0 开启接收线程
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //互斥锁
    @synchronized(self)
    {
        [self->recvData appendData:data];
//        NSLog(@"rec");
        //        self->recvData = data;
//        NSLog(@"recved--%@",[NSThread currentThread]);
    }

    //必须添加readDataWithTimeout方法
//        NSLog(@"%@",[NSThread currentThread]);
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}
@end
