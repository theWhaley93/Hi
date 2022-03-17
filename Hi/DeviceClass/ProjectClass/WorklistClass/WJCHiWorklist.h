//
//  WJCHiWorklist.h
//  Hi
//
//  Created by apple on 2018/4/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCOneParameter.h"
#import "WJCParameters.h"
#import "WJCHiCommunicator.h"


typedef enum{
    WJCWorklistOperateNone,WJCWorklistOperateDownload,WJCWorklistOperateUpload
}WJCWorklistOperate;

typedef enum{
    WJCWorklistDownloadFailStepNone,
    WJCWorklistDownloadFailStepRetry,
    WJCWorklistDownloadFailStepIgnore,
    WJCWorklistDownloadFailStepCancel
}WJCWorklistDownloadFailStep;

@protocol WJCDownloadWorklistDelegate;
/**************************************
 单个worklist item的内容
 **************************************/
@interface WJCHiWorklistItem : NSObject{
    
@public
    NSString *offlineVal;   //offlineval存放的是实际显示值，而不是hex的值
    
}
//@property (nonatomic,readonly)  NSString *settingVal;    //设定值  就是离线值

@property (nonatomic)   int index;    //索引
@property (nonatomic,copy)  NSString *sName;    //缩写


@property (nonatomic,strong)  WJCOneParameter *nowPara;  //对应的驱动器参数


- (void)initOldVerOffline;

- (instancetype)initWithIndex:(int)rIndex withSname:(NSString*)rSname withHiPara:(WJCParameters*)rPara;

+ (instancetype)hiWorklistItemWithIndex:(int)rIndex withSname:(NSString*)rSname withHiPara:(WJCParameters*)rPara;

- (instancetype)initWithString:(NSString*)rStr withHiPara:(WJCParameters*)rPara;

+ (instancetype)hiWorklistItemWithString:(NSString*)rStr withHiPara:(WJCParameters*)rPara;

#pragma mark - 生成string
- (NSString *)worklistItemToString;
#pragma mark - 离线值的读取与写入

- (NSString*)offlineStrValWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd;

- (void)setOfflineStrValWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd withStrVal:(NSString *)rStrVal;

- (NSString*)offlineHexValWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd;

- (void)setOfflineStrHexWithSubindex:(uint32_t)rSubind withArrayIndex:(uint32_t) rArrInd withStrVal:(NSString *)rHexVal;

#pragma mark - 在线值传入至设定值中
- (void)onlineValToSettingVal;
#pragma mark - 下载参数值至驱动器中
- (Boolean)downloadSettingVal:(WJCHiCommunicator*)rHicom;
@end



/**************************************
 Hi worklist类
 **************************************/
@interface WJCHiWorklist : NSObject

@property (nonatomic)  WJCWorklistDownloadFailStep downloadFailStep;   //

@property (nonatomic,copy)  NSString *name;    //worklist的名称

@property (nonatomic,strong)  WJCParameters *hiPara;  // 

@property (nonatomic,strong)  NSMutableArray<WJCHiWorklistItem*> *item;  //worklist条目

@property (nonatomic,strong)  id<WJCDownloadWorklistDelegate> theDelegate;  //

- (void)fromString:(NSString*)rStr withHiPara:(WJCParameters*)rPara;

- (instancetype)initWithString:(NSString*)rStr withHiPara:(WJCParameters*)rPara;

+ (instancetype)hiWorklistWithStr:(NSString*)rStr withHiPara:(WJCParameters*)rPara;

//创建空的worklist
- (instancetype)initWithName:(NSString *) rName withHiPara:(WJCParameters*)rPara;

#pragma mark - 在线值传入至设定值中
- (void)onlineValsToSettingVals;

#pragma mark - 下载参数值至驱动器中
- (Boolean)downloadSettingVals:(WJCHiCommunicator*)rHicom;

#pragma mark - 生成string
- (NSString *)worklistToString;
@end

@protocol WJCDownloadWorklistDelegate <NSObject>
@optional   //可选的方法
/**代理调用的下载结果
 @param rResult 下载成功还是失败
 */
- (void)downLoadWorklistResult:(Boolean)rResult failItem:(WJCHiWorklistItem*)rItem failString:(NSString *)rStr;

- (void)downloadWorklistParaFailItem:(WJCHiWorklistItem*)rItem failString:(NSString *)rStr;
@end

