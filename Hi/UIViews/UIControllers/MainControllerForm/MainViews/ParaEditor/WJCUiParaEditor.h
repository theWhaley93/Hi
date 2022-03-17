//
//  WJCUiParaEditor.h
//  Hi
//
//  Created by apple on 2018/3/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCOneParameter.h"
#import "WJCDescDealer.h"
#import "WJCHiCommunicator.h"


typedef enum{
    CR_TOOSMALL, CR_TOOBIG, CR_OK, CR_ERR
}WJCCheckRange;

@interface WJCTableItemInfo : NSObject
@property (nonatomic,strong)  NSString *infoDesc;  //
@property (nonatomic)  Boolean isSeclected;    //
@property (nonatomic)  int val;  //参数值


- (instancetype)initWithString:(NSString *)rDesc;
+ (instancetype)tableItemInfoWithString:(NSString *)rDesc;

- (instancetype)initWithDescItem:(WJCDescTabItem *)rDescItem;
+ (instancetype)tableItemInfoWithDescItem:(WJCDescTabItem *)rDescItem;

@end



@interface WJCUiParaEditor : UIViewController{
    WJCHiCommunicator *hiComm;
}
@property (nonatomic)  Boolean isOffline;    //
@property (nonatomic,strong)  WJCDescDealer *descDealer;  //参数描述
@property (nonatomic,strong)  WJCOneParameter *editPara;  //当前编辑的参数
@property (nonatomic,strong)  NSString *name;  //




- (instancetype)initWitPara:(WJCOneParameter *) para withName:(NSString *)name withDescDealer:(WJCDescDealer *)rDescDealer withSubindex:(int)rSubindex withArrayIndex:(int)rArrayIndex withCom:(WJCHiCommunicator*)rComm withOffline:(Boolean)rIsOffline;
@end
