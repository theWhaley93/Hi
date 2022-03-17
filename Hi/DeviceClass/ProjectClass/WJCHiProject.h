//
//  WJCHiProject.h
//  Hi
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJCHiWorklist.h"
#import "WJCParameters.h"
#import "WJCHiChart.h"


@interface WJCHiProject : NSObject{
    WJCParameters *hiPara;
}

@property (nonatomic,readonly)   NSInteger worklistCount;    //worklist数量
@property (nonatomic,strong)  NSMutableArray<WJCHiWorklist *> *worklists;  //worklist列表

@property (nonatomic,readonly)   NSInteger chartCount;    //曲线数量
@property (nonatomic,strong)  NSMutableArray<WJCHiChart *> *charts;  //曲线列表


- (Boolean)addWorklist:(WJCHiWorklist *)rWorklist;

- (Boolean)loadWithChartFilePath:(NSString *)rChtPath;

- (Boolean)loadWithProjectFilePath:(NSString *)rPjtPath;

- (Boolean)loadWithWorklistFilePath:(NSString *)rWltPath;

- (instancetype)initWithHiPara:(WJCParameters*)rPara;

@end
