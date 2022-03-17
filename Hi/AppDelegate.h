//
//  AppDelegate.h
//  Hi
//
//  Created by apple on 2018/1/22.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong)  NSObject *mutex;  //互斥
@end

