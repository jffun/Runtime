//
//  TapView.h
//  Runtime
//
//  Created by yulm on 16/3/3.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TapView : UIView

- (void)setTapActionWithBlock:(void (^)(void))block;

@end
