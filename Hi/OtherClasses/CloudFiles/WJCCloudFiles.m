//
//  WJCCloudFiles.m
//  Hi
//
//  Created by apple on 2018/3/14.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCCloudFiles.h"



@interface WJCCloudFiles()<NSURLSessionDataDelegate>{
    NSDate *startT;
    NSDate *endT;
    id<WJCCloudDownFileDelegate> theDelegate;
    NSInteger totalLength;
    
    Boolean cfgFilesExist;
    Boolean cfgFilesTimeOut;

    
    //cfg版本号
    int cfgid;
    NSString *cfgPlstName;
    NSString *cfgDlstName;
}




@end

@implementation WJCCloudFiles







/**
 开始下载，dlst plst,如果返回false，说明服务器端没有改参数
 */
- (Boolean)startDownload:(int)rCfdId{
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
    
    //下载前准备
    cfgid = rCfdId;
    cfgPlstName = [NSString stringWithFormat:@"%@%d%@",@"CFGID",rCfdId,@".plst"];  //@"CFGID98.plst"
    cfgDlstName = [NSString stringWithFormat:@"%@%d%@",@"CFGID",rCfdId,@".dlst"];

    cfgFilesExist = NO;
    cfgFilesTimeOut = NO;
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://101.37.83.8:8825/file/apiGetFiles?dirId=3"];
    NSDate *now = [NSDate date];
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(checkTimeOut) userInfo:nil repeats:NO];
    
//    NSData *rData = [NSData dataWithContentsOfURL:url];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.timeoutInterval = 5;
    NSURLResponse * urlResponse;
    NSError *data1Err = nil;
    NSData *rData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&data1Err];
    if (!data1Err) {
        
    } else {
//        if (rData == nil)
        {
            NSLog(@"%f",[[NSDate date] timeIntervalSinceDate:now]);
            
            cfgFilesExist = NO;
            cfgFilesTimeOut = YES;
            
            if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
            {
                
                [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT cfgId:cfgid];
                
            }
            return NO;
        }
    }

    NSLog(@"get url1 ok");
    id jsObject = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingAllowFragments error:nil];
    NSArray<NSDictionary *> *array = (NSArray *)jsObject;
    
    for ( NSDictionary *dict in array) {
        if ([dict[@"fileName"] isEqualToString:cfgPlstName]) {
            
            for ( NSDictionary *dict2 in array) {
                if ([dict2[@"fileName"] isEqualToString:cfgDlstName]) {
                    
//                    downLoadTyp = DLTyp_Plst;
//                    cfgFilesExist = YES;
                    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    

                    

                    
                    startT = [NSDate date];
                    NSString *u1 = @"http://101.37.83.8:80";
                    NSString *pUrlStr = [NSString stringWithFormat:@"%@%@",u1,dict[@"fileUrl"]];
                    NSURL *pUrl = [NSURL URLWithString:pUrlStr];
                    
                    NSString *dUrlStr = [NSString stringWithFormat:@"%@%@",u1,dict2[@"fileUrl"]];
                    NSURL *dUrl = [NSURL URLWithString:dUrlStr];
                    
                    
                    NSMutableURLRequest *dRequest = [NSMutableURLRequest requestWithURL:dUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
                    NSError *dErr = nil;
                    NSURLResponse *dResponse = nil;
                    NSData *dlstData = [NSURLConnection sendSynchronousRequest:dRequest returningResponse:&dResponse error:&dErr];
                    if (!dErr) {
                        
                    } else {
                        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
                        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
                        {
                            
                            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT cfgId:cfgid];
                            
                        }
                        return NO;
                    }
                    
                    
                    NSMutableURLRequest *pRequest = [NSMutableURLRequest requestWithURL:pUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
                    NSError *pErr = nil;
                    NSURLResponse *pResponse = nil;
                    NSData *plstData = [NSURLConnection sendSynchronousRequest:pRequest returningResponse:&pResponse error:&pErr];
                    if (!pErr) {
                        
                    } else {
                        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
                        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
                        {
                            
                            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT cfgId:cfgid];
                            
                        }
                        return NO;
                    }

                    /*
                    NSData *dlstData = [NSData dataWithContentsOfURL:dUrl];
                    
                    if (dlstData == nil) {
                        cfgFilesTimeOut = YES;
                        self->endT = [NSDate date];
                        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
                        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:)])
                        {
                            
                            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT];
                            
                        }
                        return NO;
                    }
                    
                    NSData *plstData = [NSData dataWithContentsOfURL:pUrl];//NSUTF16LittleEndianStringEncoding
                    if (plstData == nil) {
                        cfgFilesTimeOut = YES;
                        self->endT = [NSDate date];
                        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
                        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:)])
                        {
                            
                            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT];
                            
                        }
                        return NO;
                    }
                    */
                    self->endT = [NSDate date];
                    NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);

                    NSString *dlstSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/AddressListFiles/",cfgDlstName];
                    
                    NSString *plstSavePath = [NSString stringWithFormat:@"%@%@%@",dirPath,@"/AddressListFiles/",cfgPlstName];
                    NSFileManager *manger = [NSFileManager defaultManager];
                    
                    Boolean plstDownLoad = [manger createFileAtPath:plstSavePath contents:plstData attributes:nil];
                    
                    Boolean dlstDownLoad = [manger createFileAtPath:dlstSavePath contents:dlstData attributes:nil];
                    if ((plstDownLoad) && (dlstDownLoad)) {
                        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
                        {
                            
                            [theDelegate downLoadCfgFileResult:YES downResult:DOWNLOAD_SUCC cfgId:cfgid];
                            
                        }
                        return YES;
                    } else {
                        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
                        {
                            
                            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_FAIL cfgId:cfgid];
                            
                        }
                        return NO;
                    }

                    
                    
                }
                
            }
        }

    
    }
    if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
    {
        
        [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_NOTEXIST cfgId:cfgid];
        
    }
    return NO;
        
}


    


- (instancetype)initWithDelegate:(id)delegate{
    if (self = [super init]) {
        theDelegate = delegate;

    }
    return self;
}




@end
