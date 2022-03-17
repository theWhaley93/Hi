//
//  WJCRemoteClass.h
//  remoteHi
//
//  Created by apple on 2018/5/28.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface WJCRemoteClass : NSObject

@property (nonatomic,strong)  GCDAsyncSocket *tcpClient;  //
@property (nonatomic,readonly)  Boolean remoteConnected;  //


#pragma mark - 初始化
- (instancetype)initWithDelegate:(id)rDelegate;

#pragma mark - 客户端请求动作

//连接动作
- (Boolean)connectToServer:(NSString *)rIp withPort:(uint16_t)rPort;
//断开连接
- (void)diconnect;
//注册动作
- (NSInteger)registerToServerWithClientName:(NSString *)rClientName withIsPositive:(Boolean)rIsPositive withIsReconnect:(Boolean)rIsReconnect withClientVer:(NSString *)rClientVer withPinCode:(NSString *)rPinCode withHeartBeatSec:(NSInteger)rHeartBeatSec;
//打包bytes
- (NSData *)packSendBytes:(Byte)rCmd1 withCmd2:(Byte)rCmd2 withContentData:(NSData*)rContentData;
/**返回动作
 */
- (void)responseChangeGroupWithIsSuccess:(Boolean)rIsSuccess withCycleByte:(Byte)rCycleByte;
- (void)responseReadParaWithIsSuccess:(Boolean)rIsSuccess withValue:(NSString *)rValue withCycleByte:(Byte)rCycleByte;
- (void)responseWriteParaWithIsSuccess:(Boolean)rIsSuccess withCycleByte:(Byte)rCycleByte;
- (void)responseChangeModeWithIsSuccess:(Boolean)rIsSuccess withCycleByte:(Byte)rCycleByte;
- (void)responseReadOfflineChannelWithChannelData:(NSMutableData *)rChannelData withCycleByte:(Byte)rCycleByte;
- (void)responseRecordActionWithIsSuccess:(Byte)rSuccessByte withCycleByte:(Byte)rCycleByte;
#pragma mark - 转换等功能函数
//dictionary 转成string
- (NSString *)dictionaryToJsonString:(NSDictionary*)rDict;
//string 转成dictionary
- (NSDictionary *)jsonStringToDiction:(NSString *)rJsonString;

@end

/** Hi remote代理
 1.需要返回的回调动作：1.改组；2.读参；3.写参；4.读模式；5.读离线;6.record采集命令
2.不需返回，只通知的回调动作：1.通知匹配端断线；2.通知重匹配成功；3.通知被断开匹配；4.通知被匹配
3.断线，当GCDAsyncSocket disconnect时，触发
 */
@protocol WJCRemoteDelegate <NSObject>

- (void)remoteNoticeWhenOppsiteDisconnect;  //匹配断掉线
- (void)remoteNoticeWhenRematchedWithOppsiteName:(NSString *)rOppsiteName;  //重新被匹配
- (void)remoteNoticeWhenDismatched;     //被断开匹配
- (void)remoteNoticeWhenMatchedWithOppsiteName:(NSString *)rOppsiteName;  //被匹配

- (void)remoteNotNeedAnswerDirectWrite:(int)rIndex withSubindex:(int)rSubindex withArrayIndex:(int)rArrInd withValue:(NSString *)rVal withCycleByte:(Byte)rCycleByte;

- (void)remoteNeedReturnChangeGroupWithGroupIndex:(int)rGroupIndex withCycleByte:(Byte)rCycleByte;  //切换组
- (void)remoteNeedReturnReadParaWithIndex:(int)rIndex withSubindex:(int)rSubindex withArrayIndex:(int)rArrInd withCycleByte:(Byte)rCycleByte;  //读参数
- (void)remoteNeedReturnWriteParaWithIndex:(int)rIndex withSubindex:(int)rSubindex withArrayIndex:(int)rArrInd withValue:(NSString *)rVal withCycleByte:(Byte)rCycleByte;  //写参数
- (void)remoteNeedReturnChangeModeWithModeIndex:(int)rModeIndex withCycleByte:(Byte)rCycleByte;  //切换模式
- (void)remoteNeedReturnReadOfflineChannelWithChannelIndex:(int)rChannelIndex withCycleByte:(Byte)rCycleByte;  //读离线通道曲线
- (void)remoteNeedReturnRecordActionWithCommandByte:(Byte)rCommandByte withCycleByte:(Byte)rCycleByte; //record指令


- (void)socketDisconnect;

@end


