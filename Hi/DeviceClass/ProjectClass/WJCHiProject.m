//
//  WJCHiProject.m
//  Hi
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCHiProject.h"
#import "WJCHiFileExecutor.h"

@implementation WJCHiProject


//属性读取写入方法
- (NSInteger)worklistCount{
    return _worklists.count;
}

- (NSInteger)chartCount{
    return _charts.count;
}

- (Boolean)addWorklist:(WJCHiWorklist *)rWorklist{
//    if (_worklists == nil) {
//        _worklists = [[NSMutableArray alloc] init];
//    }
    [_worklists addObject:rWorklist];
    return YES;
}

- (instancetype)initWithHiPara:(WJCParameters*)rPara{
    if (self = [super init]) {
        hiPara = rPara;
        _worklists = [[NSMutableArray alloc] init];
        _charts = [[NSMutableArray alloc] init];
    }
    return  self;
}

- (Boolean)loadWithProjectFilePath:(NSString *)rPjtPath{
    
    //清空缓存
    [_worklists removeAllObjects];
    [_charts removeAllObjects];
    
    //开始文件读取
    NSError *error = nil;
//    NSString *filecContent = [NSString stringWithContentsOfFile:sPjtPath encoding:NSUTF16LittleEndianStringEncoding error:&error];
    NSData *fileData = [NSData dataWithContentsOfFile:rPjtPath];
    uint bytePos = 0;
    uint tempLen = 0;
    //获取第一块内容长度
    [fileData getBytes:&tempLen range:NSMakeRange(bytePos, 4)];
    bytePos += 4;
    
    //获取第一块内容,string
    Byte *tempBytes1;
    tempBytes1 = (Byte *)malloc(tempLen);
    [fileData getBytes:tempBytes1 range:NSMakeRange(bytePos, tempLen)];
    bytePos += tempLen;
    NSString *stringData1 = [[NSString alloc] initWithData:[NSData dataWithBytes:tempBytes1 length:tempLen] encoding:NSUTF16LittleEndianStringEncoding];
    
    int chartNum = [[WJCHiFileExecutor getTagetStringFrom:stringData1 cutString:@"chartcount"] intValue];
    int worklistNum = [[WJCHiFileExecutor getTagetStringFrom:stringData1 cutString:@"worklistcount"] intValue];
    
    free(tempBytes1);
    
    for (int i=0; i<chartNum; i++) {
        uint32_t cLen = 0;
        [fileData getBytes:&cLen range:NSMakeRange(bytePos, 4)];
        bytePos += 4;
        
        //获取当前chart内容
//        Byte cBytes[cLen];
        Byte * cBytes;
        cBytes = (Byte *)malloc( cLen );
        [fileData getBytes:cBytes range:NSMakeRange(bytePos, cLen)];
        bytePos += cLen;
        
        NSString *stringCData1 = [[NSString alloc] initWithData:[NSData dataWithBytes:cBytes length:cLen] encoding:NSUTF16LittleEndianStringEncoding];
        WJCHiChart *tempHiChart = [WJCHiChart hiChartWithStr:stringCData1];
        [_charts addObject:tempHiChart];
        free(cBytes);
        
    }
    
    for (int i=0; i<worklistNum; i++) {
        uint32_t wLen = 0;
        [fileData getBytes:&wLen range:NSMakeRange(bytePos, 4)];
        bytePos += 4;
        
        //获取当前worklist内容
        Byte *wBytes;
        wBytes = (Byte *)malloc(wLen);
        [fileData getBytes:wBytes range:NSMakeRange(bytePos, wLen)];
        bytePos += wLen;
        NSString *stringWData1 = [[NSString alloc] initWithData:[NSData dataWithBytes:wBytes length:wLen] encoding:NSUTF16LittleEndianStringEncoding];
        
        WJCHiWorklist *tempWorklist = [WJCHiWorklist hiWorklistWithStr:stringWData1 withHiPara:hiPara];
        [_worklists addObject:tempWorklist];
        free(wBytes);
    }
    
    
    
    return YES;

}

- (Boolean)loadWithWorklistFilePath:(NSString *)rWltPath{
    NSError *error = nil;
    NSString *filecContent = [NSString stringWithContentsOfFile:rWltPath encoding:NSUTF16LittleEndianStringEncoding error:&error];
//    NSData *fileData = [NSData dataWithContentsOfFile:rWltPath];
    if (error) {
        return NO;
    } else {
        
        WJCHiWorklist *tempWorklist = [WJCHiWorklist hiWorklistWithStr:filecContent withHiPara:hiPara];
        [_worklists addObject:tempWorklist];
        return YES;
    }
}

- (Boolean)loadWithChartFilePath:(NSString *)rChtPath{
    NSError *error = nil;
    NSString *filecContent = [NSString stringWithContentsOfFile:rChtPath encoding:NSUTF16LittleEndianStringEncoding error:&error];
    //    NSData *fileData = [NSData dataWithContentsOfFile:rWltPath];
    if (error) {
        return NO;
    } else {
        
        WJCHiChart *tempChart = [WJCHiChart hiChartWithStr:filecContent];
        [_charts addObject:tempChart];
        return YES;
    }
}

@end
