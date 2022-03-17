//
//  WJCCloudFiles.h
//  Hi
//
//  Created by apple on 2018/3/14.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    DOWNLOAD_SUCC,DOWNLOAD_TIMOUT,DOWNLOAD_NOTEXIST,DOWNLOAD_FAIL
}WJCDownLoadResult;

@protocol WJCCloudDownFileDelegate;


@interface WJCCloudFiles : NSObject




/**
 开始下载，dlst plst,如果返回false，说明服务器端没有改参数
 */
- (Boolean)startDownload:(int)rCfdId;



/*初始化
 */
- (instancetype)initWithDelegate:(id)delegate;

@end





@protocol WJCCloudDownFileDelegate <NSObject>
@optional   //可选的方法
/**代理调用的下载结果
 @param rResult 下载成功还是失败
 */
- (void)downLoadCfgFileResult:(Boolean)rResult downResult:(WJCDownLoadResult)rDownResult cfgId:(int) rCfgId;
@end
