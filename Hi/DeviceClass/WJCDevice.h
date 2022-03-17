//
//  WJCDevice.h
//  Hi
//
//  Created by apple on 2018/3/5.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCParameters.h"
#import "WJCDescDealer.h"
#import "WJCHiCommunicator.h"
#import "WJCPerUnitValues.h"
#import "WJCHiProject.h"
#import "WJCGlobalConstants.h"
#import "WJCCommonFunctions.h"

typedef enum{
    UPDATE_SUCC,UPDATE_FAIL,UPDATE_UPDATING
}WJCUpdateState;

@protocol WJCUpdateFileDelegate;

@interface WJCDevice : NSObject{
    @public
    id<WJCUpdateFileDelegate> theDelegate;
}
@property (nonatomic,strong)  NSString *connectedIP;

@property (nonatomic)  Boolean isOffline;  //是否离线

@property (nonatomic)  int cfgId;  //参数版本号

@property (nonatomic,strong)  WJCDriverState *driverState;  //驱动器状态

@property (nonatomic,strong)  WJCPerUnitValues *perUnitValues;  //标幺值

@property (nonatomic,strong)  WJCHiCommunicator *hiCom;  //通讯

@property (nonatomic,strong)  WJCDescDealer *descDealer;  //参数描述类

@property (nonatomic,strong)  WJCParameters *paras;  //参数类

@property (nonatomic,strong)  WJCHiProject *projectManger;  //工程管理器：管理worklist project




/** 文件载入
 */
- (Boolean)loadFileWithCfgId:(NSInteger)cfgid;

/** 参数文件在线更新
 */
- (Boolean)updateCfgFile;


- (Boolean)createHiCom:(NSString *) ip OnPort:(uint16_t)port;




@end

@protocol WJCUpdateFileDelegate <NSObject>
@optional   //可选的方法
/**代理调用的下载结果

 */
- (void)updateCfgFileResult:(Boolean)rResult updateState:(WJCUpdateState)rUpdateState updateInfo:(NSString*)rUpdateStr updateProgress:(float)rUpdateProgress;
@end


extern WJCDevice *hiDevice;
