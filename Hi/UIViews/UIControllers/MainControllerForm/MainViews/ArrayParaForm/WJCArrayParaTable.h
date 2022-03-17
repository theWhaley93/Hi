//
//  WJCArrayParaTable.h
//  Hi
//
//  Created by apple on 2018/4/3.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCHiCommunicator.h"
#import "WJCDescDealer.h"
#import "WJCOneParameter.h"
#import "WJCHiWorklist.h"
#import "WJCDevice.h"

@interface WJCArrayParaTable : UITableViewController

- (instancetype)initWithDescDealer:(WJCDescDealer *) rDescDealer withPara:(WJCOneParameter *) rPara withComm:(WJCHiCommunicator *)rHiCom withIsOffline:(Boolean) rIsOffline withParaName:(NSString *)rName withSubindex:(int) rSubindex;

- (instancetype)initWithWorklistItem:(WJCHiWorklistItem *)rWorklistItem withHiDevice:(WJCDevice *)rDevice withParaName:(NSString *)rName withSubindex:(int) rSubindex;
@end
