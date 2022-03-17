//
//  WJCFilesManger.m
//  test2
//
//  Created by apple on 2018/5/4.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCFilesManger.h"

/***********************
 本地文件类型
 **********************/
@implementation WJCLoaclFileItem


- (instancetype)initWithFileDir:(NSString *)rFileDir withFileName:(NSString *)rFileName withIsDir:(Boolean)rIsDir withFileType:(WJCFileType)rFileType{
    if (self = [super init]) {
        _fileDir = rFileDir;
        _fileName = rFileName;
        _isDir = rIsDir;
        _filePath = [NSString stringWithFormat:@"%@%@%@",_fileDir,@"/",_fileName];
        _fileType = rFileType;
        if (_fileType != WJCFileTypeDirectory) {
            _fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] fileSize];
        }
//        [[NSFileManager defaultManager] fileExistsAtPath:_filePath isDirectory:&_isDir];

    }
    return self;
}
+ (instancetype)localFileItemWithFileDir:(NSString *)rFileDir withFileName:(NSString *)rFileName withIsDir:(Boolean)rIsDir withFileType:(WJCFileType)rFileType{
    return [[WJCLoaclFileItem alloc] initWithFileDir:rFileDir withFileName:rFileName withIsDir:rIsDir withFileType:rFileType];
}
@end



/***********************
 文件管理器
 **********************/
@implementation WJCLocalFilesManger

- (void)loadLocalFilesFromDir:(NSString *)rDir{
    [_localFileList removeAllObjects];
    
    NSError *error = nil;
    _nowLocalDir = rDir;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rDir error:&error];
    
    if (![_rootLocalDir isEqualToString:rDir]) {
        NSString *parentDir = [rDir stringByDeletingLastPathComponent];
        WJCLoaclFileItem *tempItem = [WJCLoaclFileItem localFileItemWithFileDir:parentDir withFileName:@"" withIsDir:YES withFileType:WJCFileTypeDirectory];
        tempItem.isReturn = YES;
        [_localFileList addObject:tempItem];
    }
    
    for (NSString *tempS in fileList) {
        
        
        NSString *tempFilePath = [NSString stringWithFormat:@"%@%@%@",rDir,@"/",tempS];
        Boolean tempIsDir;
        
        [[NSFileManager defaultManager] fileExistsAtPath:tempFilePath isDirectory:&tempIsDir];
        Boolean tempIsHiFile = NO;
        WJCFileType tempHiFileType;
        if (tempIsDir) {
            tempHiFileType = WJCFileTypeDirectory;
        }
        
        if ([tempS hasSuffix:@".hiprj"]) {
            tempIsHiFile = YES;
            tempHiFileType = WJCFileTypeProject;
        } else if ([tempS hasSuffix:@".htnwk"]) {
            tempIsHiFile = YES;
            tempHiFileType = WJCFileTypeWorklist;
        } else if ([tempS hasSuffix:@".hichrt"]) {
            tempIsHiFile = YES;
            tempHiFileType = WJCFileTypeChart;
        }
        
        if ((tempIsDir) || (tempIsHiFile)) {
            WJCLoaclFileItem *tempItem = [WJCLoaclFileItem localFileItemWithFileDir:rDir withFileName:tempS withIsDir:tempIsDir withFileType:tempHiFileType];
            [_localFileList addObject:tempItem];
        }
        

    }
}

- (instancetype)initWithRootLocalDir:(NSString *)rDir{
    if (self = [super init]) {
        _localFileList = [[NSMutableArray alloc] init];
        _rootLocalDir = rDir;
        [self loadLocalFilesFromDir:rDir];
    }
    return self;
}

@end


/***********************
 云端文件类型
 **********************/
//云端的文件结构，在文件夹内
@implementation WJCCloudFileItem


- (instancetype)initWithDict:(NSDictionary *)rDict{
    if (self = [super init]) {
//        @property (nonatomic,strong)  NSString *fileId;  //
//        @property (nonatomic,strong)  NSString *fileName;   //
//        @property (nonatomic,strong)  NSString *fileSize;  //
//        @property (nonatomic,strong)  NSString *fileDesc;   //
//        @property (nonatomic,strong)  NSString *fileDirName;  //
//        @property (nonatomic)  WJCFileType fileType;   //文件类型
        _fileId = rDict[@"id"];
        _fileName = rDict[@"fileName"];
        _fileSize = rDict[@"fileSize"];
        _fileDesc = rDict[@"fileDesc"];
        _fileDirName = rDict[@"fileDirName"];
        
        NSString *u1 = @"http://101.37.83.8:80";
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",u1,rDict[@"fileUrl"]];
        
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        _fileUrl = [NSURL URLWithString:urlStr];
        
//        NSString *fileUrl1 = @"http://101.37.83.8:80";
//        _fileUrl = [NSString stringWithFormat:@"%@%@",fileUrl1,rDict[@"fileUrl"]];//rDict[@"fileUrl"];
        NSString *fileTypeName = rDict[@"fileType"];
        if ([fileTypeName isEqualToString:@"hiprj"]) {
            _fileType = WJCFileTypeProject;
        } else if ([fileTypeName isEqualToString:@"hichrt"]){
            _fileType = WJCFileTypeChart;
        } else if ([fileTypeName isEqualToString:@"htnwk"]){
            _fileType = WJCFileTypeWorklist;
        }
        
    }
    return self;
}

+ (instancetype)cloudFileItemWithDict:(NSDictionary *) rDict{
    return [[WJCCloudFileItem alloc] initWithDict:rDict];
}
@end
//云端的文件夹结构
@implementation WJCCloudDirItem

- (instancetype)initWithDict:(NSDictionary *)rDict{
    if (self = [super init]) {
        _dirId = rDict[@"id"];
        _dirName = rDict[@"dirName"];
        _dirParentId = rDict[@"dirParentId"];
        _dirDesc = rDict[@"dirDesc"];
    }
    return self;
}

+ (instancetype)cloudDirItemWithDict:(NSDictionary *) rDict{
    return [[WJCCloudDirItem alloc] initWithDict:rDict];
}


@end
/***********************
 云端文件夹管理器
 **********************/
@implementation WJCCloudFilesManger


- (instancetype)initWithDelegate:(id)rDelegate{
    if (self = [super init]) {
        theDelegate = rDelegate;
        _dirList = [[NSMutableArray alloc] init];
        _fileList = [[NSMutableArray alloc] init];
        _level = 0;
    }
    return self;
}
- (Boolean)getDirList{
    [_dirList removeAllObjects];
    NSURL *url = [NSURL URLWithString:@"http://101.37.83.8:8825/file/apiGetFileDirs"];
    NSData *rData = [NSData dataWithContentsOfURL:url];
    if (rData == nil) {
        return NO;
    } else {
        id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
        NSArray<NSDictionary *> *array = (NSArray *)jsObject;
        for ( NSDictionary *tempDict in array) {
            WJCCloudDirItem *tempDir = [[WJCCloudDirItem alloc] initWithDict:tempDict];
            [_dirList addObject:tempDir];
        }
        
        return YES;
    }
}
- (Boolean)getFileListWithDirId:(NSString*)rDirId{
    [_fileList removeAllObjects];
    WJCCloudFileItem *tempFFile = [[WJCCloudFileItem alloc] init];
    tempFFile.isReturn = true;
    [_fileList addObject:tempFFile];
    
    _nowDirFile = rDirId;
    
    NSString *urlStrP1 = @"http://101.37.83.8:8825/file/apiGetFiles?dirId=";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlStrP1,rDirId]];
    NSData *rData = [NSData dataWithContentsOfURL:url];
    
    if (rData == nil) {
        return NO;
    } else {
        id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
        NSArray<NSDictionary *> *array = (NSArray *)jsObject;
        
        
        for ( NSDictionary *tempDict in array) {
            NSString *tempFileStyle = tempDict[@"fileType"];
            if ([tempFileStyle isEqualToString:@"htnwk"] || [tempFileStyle isEqualToString:@"hiprj"] || [tempFileStyle isEqualToString:@"hichrt"]) {
                WJCCloudFileItem *tempFile = [[WJCCloudFileItem alloc] initWithDict:tempDict];
                [_fileList addObject:tempFile];
            }
        }
        
        return YES;
    }
}

- (Boolean)downloadCloudFileWithFileItem:(WJCCloudFileItem *)rFileItem{

    
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",rFileItem.fileUrl);

    
    NSMutableURLRequest *dRequest = [NSMutableURLRequest requestWithURL:rFileItem.fileUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
    NSError *dErr = nil;
    NSURLResponse *dResponse = nil;
    NSData *tempFileData = [NSURLConnection sendSynchronousRequest:dRequest returningResponse:&dResponse error:&dErr];
    
    if (!dErr) {
        
    } else {
        //        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT cfgId:0];
            
        }
        return NO;
    }
    
    


    
    NSString *fileSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/",rFileItem.fileName];
    rFileItem.dowloadFilePath = fileSavePath;
//    NSString *plstSavePath = [NSString stringWithFormat:@"%@%@%@%@",dirPath,@"/AddressListFiles/",_fileName,@".plst"];
    NSFileManager *manger = [NSFileManager defaultManager];
    
    
    Boolean fileDownLoad = [manger createFileAtPath:fileSavePath contents:tempFileData attributes:nil];
    if (fileDownLoad) {
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:YES downResult:DOWNLOAD_SUCC cfgId:0];
            
        }
        return YES;
    } else {
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_FAIL cfgId:0];
            
        }
        return NO;
    }
    
}

@end


