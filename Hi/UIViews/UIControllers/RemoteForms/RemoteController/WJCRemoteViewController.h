//
//  WJCRemoteViewController.h
//  Hi
//
//  Created by apple on 2018/5/31.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCRemoteClass.h"
#import "WJCDevice.h"

@interface WJCRemoteViewController : UIViewController


@property (nonatomic,strong)  WJCDevice *nowDevice;  //
@property (nonatomic,strong)  WJCRemoteClass *nowRemoteController;  //


- (instancetype)initWithHiDevice:(WJCDevice *)rDevice;

@end
