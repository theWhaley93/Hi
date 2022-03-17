//
//  WJCFilesViewController.h
//  Hi
//  文件管理器，可以打开本地和云端的工程 worklist和chart文件
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJCDevice.h"

@interface WJCFilesViewController : UIViewController

- (instancetype)initWithDevice:(WJCDevice *) rDevice;

@end
