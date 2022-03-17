//
//  WJCHiFileExecutor.m
//  Hi
//
//  Created by apple on 2018/1/23.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "WJCHiFileExecutor.h"
#import "WJCGlobalConstants.h"

@implementation WJCHiFileExecutor
/**
 打开文件，plst，dlst
 */
+ (NSString *)openPlstFile:(uint32_t) cfgId error:(NSError **)err{
//    NSString *home = NSHomeDirectory();
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
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *file = [NSString stringWithFormat:@"%@%d%@",@"AddressListFiles/CFGID",cfgId,@".plst"];

    NSString *filePath = [NSString stringWithFormat:@"%@%@%@",documentPath,@"/",file];//[[NSBundle mainBundle] pathForResource:file ofType:nil];
    NSError *error = nil;
    NSString *filecContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];//[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
    
    if (err)
        *err = error;
    
    if (error) {
        return @"Open_Error";
    } else {
        return filecContent;
    }
}

+ (NSString *)openDlstFile:(uint32_t) cfgId error:(NSError **)err{
    //    NSString *home = NSHomeDirectory();
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *file = [NSString stringWithFormat:@"%@%d%@",@"AddressListFiles/CFGID",cfgId,@".dlst"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%@%@",documentPath,@"/",file]; //[[NSBundle mainBundle] pathForResource:file ofType:nil];
    NSError *error = nil;
    NSString *filecContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];//[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF16LittleEndianStringEncoding error:&error];
    
    if (err)
        *err = error;
    
    if (error) {
        return @"Open_Error";
    } else {
        return filecContent;
    }
}

/**
 从字符串中截取需要的字符，对于原plst，dlst文件
 例如从<\addresscount\>1502</addresscount/>中截取1502
 
 @param wholeString 待处理的字符串
 @param cutString 输入标示字符串 例如addresscount
 @return 目标字符串,没找到返回Not_Found
 */
+ (NSString *)getTagetStringFrom: (NSString *) wholeString cutString:(NSString *)cutString {

    NSString *s1 = [NSString stringWithFormat:@"%@%@%@",@"<\\",cutString,@"\\>"];   //"\\"表示"\"，因为单独的\用作转义字符，所以用双反斜杠"\"表示\
//    NSString *s1 = cutString;
    NSString *s2 = [NSString stringWithFormat:@"%@%@%@",@"</",cutString,@"/>"];
    NSRange range1 = [wholeString rangeOfString:s1];
    NSRange range2 = [wholeString rangeOfString:s2];
    if (range2.length>0) {
        NSRange range3 = NSMakeRange(range1.location+range1.length,range2.location-range1.location-range1.length);
        return [wholeString substringWithRange:range3];
    }
    
    return NOT_FOUND;
    
}

//创建<//>结构的内容
//创建<//>结构的内容
+ (NSString *)makeTargetStringWithContentString:(NSString *)rContentStr withTittleString:(NSString *)tTittleStr{
    NSString *s1 = [NSString stringWithFormat:@"%@%@%@",@"<\\",tTittleStr,@"\\>"];   //"\\"表示"\"，因为单独的\用作转义字符，所以用双反斜杠"\"表示\
    //    NSString *s1 = cutString;
    NSString *s2 = [NSString stringWithFormat:@"%@%@%@",@"</",tTittleStr,@"/>"];
    NSString *resultString = [NSString stringWithFormat:@"%@%@%@",s1,rContentStr,s2];
    return resultString;
}
//+ (NSError *)fileOpenError:(NSString *)errMsg
//{
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
//    
//    return [NSError errorWithDomain:@"File opened error"
//                               code:0
//                           userInfo:userInfo];
//}


/* 从服务器下载plst和dlst，如果没有返回false，如果有返回true，并从服务器下载到本地目录
 */
+ (Boolean)downloadFromServer:(NSString *)fileName filepath:(NSString *) path{
    Boolean reB = false;
    
    return reB;
}

/* 载入plst文件，如果本地有，从本地载入，如果没有从云端载入，如果云端也没有，显示没找到该文件
 */
+ (NSString *)loadPlstFile:(uint32_t) cfgId error:(NSError **)err{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager * file = [NSFileManager defaultManager];
    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/AddressListFiles"];
    Boolean isExist = [file fileExistsAtPath:addressP];
    
    if (!isExist) {
        [file createDirectoryAtPath:addressP withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return @"";
}


/* 查询本地是否有plst和dlst文件
 */
+ (Boolean)searchCfgFilesLocal:(int)rCfgId{
    //先判断有没有AddressListFiles文件夹
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager * file = [NSFileManager defaultManager];
    NSString * addressP = [NSString stringWithFormat:@"%@%@",documentPath,@"/AddressListFiles"];
    Boolean isExist = [file fileExistsAtPath:addressP];
    
    if (!isExist) {//如果没有，先创建AddressListFiles文件夹
        [file createDirectoryAtPath:addressP withIntermediateDirectories:YES attributes:nil error:nil];
        return NO;
    }
    
    NSString *cfgPlstPath = [NSString stringWithFormat:@"%@%@%@",addressP,@"/",[NSString stringWithFormat:@"%@%d%@",@"CFGID",rCfgId,@".plst"]];  //@"CFGID98.plst"
    NSString *cfgDlstPath = [NSString stringWithFormat:@"%@%@%@",addressP,@"/",[NSString stringWithFormat:@"%@%d%@",@"CFGID",rCfgId,@".dlst"]];
    
    if (([file fileExistsAtPath:cfgPlstPath]) && ([file fileExistsAtPath:cfgDlstPath])) {
        return YES;
    }
    return NO;
}


@end
