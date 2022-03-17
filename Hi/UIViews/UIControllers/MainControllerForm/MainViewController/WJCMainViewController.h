//
//  WJCMainViewController.h
//  Hi
//
//  Created by apple on 2018/4/10.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJCMainViewController : UITabBarController

@property (nonatomic)  Boolean isOffline;    //

- (instancetype)initWithIsOffline:(Boolean)rIsOffline;
@end
