//
//  WJCDatasetParaTable.h
//  Hi
//
//  Created by apple on 2018/4/2.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiCommunicator.h"
#import "WJCDescDealer.h"
#import "WJCOneParameter.h"

@interface WJCDatasetParaTable : UITableViewController{
    WJCHiCommunicator *hiComm;
    Boolean isOffline;
}

@property (nonatomic,strong)  WJCDescDealer *descDealer;  //参数描述
@property (nonatomic,strong)  WJCOneParameter *nowPara;  //当前编辑的参数

- (instancetype)initWithDescDealer:(WJCDescDealer *) rDescDealer withPara:(WJCOneParameter *) rPara withComm:(WJCHiCommunicator *)rHiCom withIsOffline:(Boolean) rIsOffline withParaName:(NSString *)rName;

@end
