//
//  WJCFilesManger.h
//  test2
//
//  Created by apple on 2018/5/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCCloudFiles.h"
typedef enum {
    WJCFileTypeDirectory,   //文件
    WJCFileTypeWorklist,         //文件类型
    WJCFileTypeChart,
    WJCFileTypeProject
}WJCFileType;

/***********************
 本地文件类型
 **********************/
@interface WJCLoaclFileItem : NSObject

@property (nonatomic,strong)  NSString *filePath;  //文件完整路径，包括文件名
@property (nonatomic,strong)  NSString *fileDir;  //文件所在目录的路径，不包括文件名
@property (nonatomic,strong)  NSString *fileName;  //带后缀名的文件名

@property (nonatomic)  Boolean isReturn;   //是否为返回上一目录
@property (nonatomic)  Boolean isDir;   //是否文件夹
@property (nonatomic)  WJCFileType fileType;   //文件类型
@property (nonatomic)  unsigned long long fileSize;   //文件类型

- (instancetype)initWithFileDir:(NSString *) rFileDir withFileName:(NSString *) rFileName withIsDir:(Boolean)rIsDir withFileType:(WJCFileType)rFileType;
+ (instancetype)localFileItemWithFileDir:(NSString *) rFileDir withFileName:(NSString *) rFileName withIsDir:(Boolean)rIsDir withFileType:(WJCFileType)rFileType;

@end

/***********************
 本地文件管理器
 **********************/
@interface WJCLocalFilesManger : NSObject

@property (nonatomic,strong)  NSMutableArray<WJCLoaclFileItem *> *localFileList;  //本地文件

@property (nonatomic,strong)  NSString *nowLocalDir;  //当前打开的文件目录
@property (nonatomic,strong)  NSString *rootLocalDir;  //当前打开的文件最高级目录
- (void)loadLocalFilesFromDir:(NSString *) rDir;    //打开当前的文件目录

- (instancetype)initWithRootLocalDir:(NSString *)rDir;

@end


/***********************
 云端文件类型
 **********************/
//云端的文件结构，在文件夹内
@interface WJCCloudFileItem: NSObject

@property (nonatomic,strong)  NSString *fileId;  //
@property (nonatomic,strong)  NSString *fileName;   //
@property (nonatomic,strong)  NSString *fileSize;  //
@property (nonatomic,strong)  NSString *fileDesc;   //
@property (nonatomic,strong)  NSString *fileDirName;  //
@property (nonatomic,strong)  NSURL *fileUrl;   //
@property (nonatomic,strong)  NSString *dowloadFilePath;  //下载后的参数地址 

@property (nonatomic)  WJCFileType fileType;   //文件类型
@property (nonatomic)  Boolean isReturn;   //文件类型

- (instancetype)initWithDict:(NSDictionary *)rDict;
+ (instancetype)cloudFileItemWithDict:(NSDictionary *) rDict;

@end
//云端的文件夹结构
@interface WJCCloudDirItem: NSObject

@property (nonatomic,strong)  NSString *dirId;  //
@property (nonatomic,strong)  NSString *dirParentId;  //
@property (nonatomic,strong)  NSString *dirName;   //
@property (nonatomic,strong)  NSString *dirDesc;   //

- (instancetype)initWithDict:(NSDictionary *)rDict;
+ (instancetype)cloudDirItemWithDict:(NSDictionary *) rDict;
@end
/***********************
 云端文件夹管理器
 **********************/
@interface WJCCloudFilesManger: NSObject{
    id<WJCCloudDownFileDelegate> theDelegate;
}

@property (nonatomic)  int level;  //0:表示文件夹目录  1:表示文件目录
@property (nonatomic,strong)  NSString *nowDirFile;   //
@property (nonatomic,strong)  NSMutableArray<WJCCloudDirItem *> *dirList;  //
@property (nonatomic,strong)  NSMutableArray<WJCCloudFileItem *> *fileList;  //某个目录下的文件

- (instancetype)initWithDelegate:(id)rDelegate;

- (Boolean)getDirList;
- (Boolean)getFileListWithDirId:(NSString*)rDirId;

- (Boolean)downloadCloudFileWithFileItem:(WJCCloudFileItem *)rFileItem;

@end


