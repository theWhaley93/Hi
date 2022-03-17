//
//  WJCCfgFileModel.h
//  Hi
//
//  Created by apple on 2018/3/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCCloudFiles.h"


@interface WJCCfgFileModel : NSObject{
    @public
    Boolean localExist; //本地是否存在
    Boolean cloudExist; //云端是否存在
    id<WJCCloudDownFileDelegate> theDelegate;
}
@property (nonatomic,copy)  NSString *fileName;    //参数文件名
@property (nonatomic)   int cfgId;  //cfgId号

@property (nonatomic,copy) NSString *DSPVersion;
@property (nonatomic,copy)  NSURL *plstUrl;
@property (nonatomic,copy)  NSURL *dlstUrl;    //dlst url

- (instancetype)initWithFileName:(NSString *)rFileName;
- (void)getInfoFromCloudWithPlstDic:(NSDictionary *) rPlstDic withDlstDic:(NSDictionary *) rDlstDic;

- (Boolean)downloadCfgFiles;
@end
