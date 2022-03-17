//
//  WJCCfgFileListModel.m
//  Hi
//
//  Created by apple on 2018/3/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCCfgFileListModel.h"

@interface WJCCfgFileListModel()
@property (nonatomic)  NSDictionary *DSPVerDict;  //

@end

@implementation WJCCfgFileListModel


- (instancetype)init{
    _fileList = [[NSMutableArray alloc] init];
    
    
    NSString *plistFilename = [[NSBundle mainBundle] pathForResource:@"HiVersion" ofType:@"plist"];
    self.DSPVerDict = [NSDictionary dictionaryWithContentsOfFile:plistFilename];
    NSString * t1 = self.DSPVerDict[@"11"];
    NSString * t2 = self.DSPVerDict[@"CFGID118"];
    [self loadFromLocal:@""];
    
    
    return self;
}

- (void)loadFromLocal:(NSString *)rDirPath{
    //先判断有没有AddressListFiles文件夹
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/AddressListFiles"];
    Boolean isExist = [fileManger fileExistsAtPath:addressP];
    
    if (!isExist) {//如果没有，先创建AddressListFiles文件夹
        [fileManger createDirectoryAtPath:addressP withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSArray *fileArray = [fileManger contentsOfDirectoryAtPath:addressP error:nil];
        NSMutableArray *dlstFiles = [[NSMutableArray alloc] init];
        NSMutableArray *plstFiles = [[NSMutableArray alloc] init];
        for (NSString *str in fileArray) {
            if ([str hasSuffix:@".dlst"]) {
                [dlstFiles addObject:str];
            } else if ([str hasSuffix:@".plst"]){
                [plstFiles addObject:str];
            }
        }
        
        for (NSString *tempS in plstFiles) {
            NSArray *nameArr = [tempS componentsSeparatedByString:@"."];
            if (nameArr.count == 2) {
                NSString *nameP1 = nameArr[0];
                NSString *dlstName = [NSString stringWithFormat:@"%@%@",nameP1,@".dlst"];
                for (int i=0; i<dlstFiles.count; i++) {
                    if ([dlstName isEqualToString:dlstFiles[i]]) {
                        WJCCfgFileModel *tempItem = [[WJCCfgFileModel alloc] initWithFileName:nameP1];
                        tempItem->localExist = YES;
                        tempItem.DSPVersion = self.DSPVerDict[nameP1];
                        [_fileList addObject:tempItem];
                    }
                }
            }

        }
    }
    
    
    
}

- (void)loadFromCloud{
    //NSString *home = NSHomeDirectory();
    
    /*
     NSURL *url = [NSURL URLWithString:@"http://101.37.83.8:8825/file/apiGetFiles?dirId=3"];
     NSData *rData = [NSData dataWithContentsOfURL:url];
     //    NSString *dStr = [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding];
     id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
     NSArray *array = (NSArray *)jsObject;
     
     NSURL *url2 = [NSURL URLWithString:@"http://101.37.83.8:80/fileupload/fileupload/1492130287434.plst"];
     NSData *rData2 = [NSData dataWithContentsOfURL:url2];
     
     NSString *st = [[NSString alloc] initWithData:rData2 encoding:NSUTF16LittleEndianStringEncoding];
     */
    NSMutableArray<WJCCfgFileModel*> *tempCloudFiles = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://101.37.83.8:8825/file/apiGetFiles?dirId=3"];
    NSDate *now = [NSDate date];
    //    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(checkTimeOut) userInfo:nil repeats:NO];
    
    NSData *rData = [NSData dataWithContentsOfURL:url];
    if (rData == nil) {
        NSLog(@"%f",[[NSDate date] timeIntervalSinceDate:now]);
        
    } else {
        
        NSLog(@"get url1 ok");
        id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
        NSArray<NSDictionary *> *array = (NSArray *)jsObject;
        
        for ( NSDictionary *pDict in array) {
            if ([pDict[@"fileType"] isEqualToString:@"plst"]) {
                NSString *name = pDict[@"fileName"];
                NSArray *nameArr = [name componentsSeparatedByString:@"."];
                if (nameArr.count == 2) {
                    NSString *namePart1 = nameArr[0];
                    NSString *nameDlst = [NSString stringWithFormat:@"%@%@",namePart1,@".dlst"];
                    for (NSDictionary *dDict in array) {
                        if ([dDict[@"fileName"] isEqualToString:nameDlst]) {
                            WJCCfgFileModel *tempItem = [[WJCCfgFileModel alloc] initWithFileName:namePart1];
                            [tempItem getInfoFromCloudWithPlstDic:pDict withDlstDic:dDict];
                            tempItem->cloudExist = YES;
                            tempItem->localExist = NO;
                            tempItem.DSPVersion = self.DSPVerDict[namePart1];
                            [tempCloudFiles addObject:tempItem];
                            break;
                        }
                    }
                }
            }

        
        }
        NSLog(@"%d",tempCloudFiles.count);
        
        for (WJCCfgFileModel *tempC in tempCloudFiles) {
            Boolean isSame = NO;
//            if ((_fileList == nil) || (_fileList.count == 0)) {
//                break;
//            }
            for (int j=0; j<_fileList.count; j++) {
                if ([tempC.fileName isEqualToString:_fileList[j].fileName]) {
                    _fileList[j]->cloudExist = YES;
                    isSame = YES;
                    break;
                }
            }
            
            if (!isSame) {
                [_fileList addObject:tempC];
            }
            
        }
    }

    
}


@end
