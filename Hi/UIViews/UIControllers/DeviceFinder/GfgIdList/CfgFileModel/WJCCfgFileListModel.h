//
//  WJCCfgFileListModel.h
//  Hi
//
//  Created by apple on 2018/3/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCCfgFileModel.h"

@interface WJCCfgFileListModel : NSObject

@property (nonatomic,strong)  NSMutableArray<WJCCfgFileModel *> *fileList;  //获取本地和云端的文件列表


- (void)loadFromLocal:(NSString *)rDirPath;

- (void)loadFromCloud;

@end
