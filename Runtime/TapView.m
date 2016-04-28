//
//  TapView.m
//  Runtime
//
//  Created by yulm on 16/3/3.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import "TapView.h"
#import <objc/runtime.h>

const void * kDTActionHandlerTapGestureKey;
const void * kDTActionHandlerTapBlockKey;

@implementation TapView

- (void)setTapActionWithBlock:(void (^)(void))block {
    //将手势对象及操作的block对象关联到self中
    
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerTapGestureKey);
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        
        //将手势对象关联
        objc_setAssociatedObject(self, &kDTActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    //将操作的block关联
    objc_setAssociatedObject(self, &kDTActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)_handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    //在手势对象的action中处理方法
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        void(^action)(void) = objc_getAssociatedObject(self, &kDTActionHandlerTapBlockKey);
        if (action) {
            action();
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
