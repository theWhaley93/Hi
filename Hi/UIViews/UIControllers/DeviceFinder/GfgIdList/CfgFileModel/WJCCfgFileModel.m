//
//  WJCCfgFileModel.m
//  Hi
//
//  Created by apple on 2018/3/30.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCCfgFileModel.h"

@interface WJCCfgFileModel()

@end

@implementation WJCCfgFileModel


- (instancetype)initWithFileName:(NSString *)rFileName{
    if (self = [super init]) {
        _fileName = rFileName;
        NSString *tempS = [_fileName substringFromIndex:5];
        _cfgId = [tempS intValue];
    }
    return self;
}

- (void)getInfoFromCloudWithPlstDic:(NSDictionary *) rPlstDic withDlstDic:(NSDictionary *) rDlstDic{
    //       NSString *u1 = @"http://101.37.83.8:80";
    NSString *u1 = @"http://101.37.83.8:80";
    NSString *pUrlStr = [NSString stringWithFormat:@"%@%@",u1,rPlstDic[@"fileUrl"]];
    self.plstUrl = [NSURL URLWithString:pUrlStr];
    
    NSString *dUrlStr = [NSString stringWithFormat:@"%@%@",u1,rDlstDic[@"fileUrl"]];
    self.dlstUrl = [NSURL URLWithString:dUrlStr];
}

- (Boolean)downloadCfgFiles{
    
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    
    
    NSMutableURLRequest *dRequest = [NSMutableURLRequest requestWithURL:_dlstUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
    NSError *dErr = nil;
    NSURLResponse *dResponse = nil;
    NSData *dlstData = [NSURLConnection sendSynchronousRequest:dRequest returningResponse:&dResponse error:&dErr];
    
    if (!dErr) {
        
    } else {
//        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT cfgId:_cfgId];
            
        }
        return NO;
    }
    
    
    NSMutableURLRequest *pRequest = [NSMutableURLRequest requestWithURL:_plstUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:6];
    NSError *pErr = nil;
    NSURLResponse *pResponse = nil;
    NSData *plstData = [NSURLConnection sendSynchronousRequest:pRequest returningResponse:&pResponse error:&pErr];
    if (!pErr) {
        
    } else {
//        NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_TIMOUT cfgId:_cfgId];
            
        }
        return NO;
    }
    

//    self->endT = [NSDate date];
//    NSLog(@"%f",[self->endT timeIntervalSinceDate:self->startT]);
    
    NSString *dlstSavePath = [NSString stringWithFormat:@"%@%@%@%@",dirPath,@"/AddressListFiles/",_fileName,@".dlst"];
    
    NSString *plstSavePath = [NSString stringWithFormat:@"%@%@%@%@",dirPath,@"/AddressListFiles/",_fileName,@".plst"];
    NSFileManager *manger = [NSFileManager defaultManager];
    
    Boolean plstDownLoad = [manger createFileAtPath:plstSavePath contents:plstData attributes:nil];
    
    Boolean dlstDownLoad = [manger createFileAtPath:dlstSavePath contents:dlstData attributes:nil];
    if ((plstDownLoad) && (dlstDownLoad)) {
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:YES downResult:DOWNLOAD_SUCC cfgId:_cfgId];
            
        }
        return YES;
    } else {
        if ([theDelegate respondsToSelector:@selector(downLoadCfgFileResult:downResult:cfgId:)])
        {
            
            [theDelegate downLoadCfgFileResult:NO downResult:DOWNLOAD_FAIL cfgId:_cfgId];
            
        }
        return NO;
    }
    
    
    

}

@end


