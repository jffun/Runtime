//
//  UIViewController+LoadingView.m
//  Runtime
//
//  Created by yulm on 16/5/4.
//  Copyright © 2016年 Wanda. All rights reserved.
//

#import "UIViewController+LoadingView.h"
#import <objc/runtime.h>

const static char loadingViewKey;

@implementation UIViewController (LoadingView)

- (UIView *)loadingView {
    return objc_getAssociatedObject(self, &loadingViewKey);
}

- (void)setLoadingView:(UIView *)loadingView {
    objc_setAssociatedObject(self, &loadingViewKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showLoadingView {
    if (!self.loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingView = loadingView;
        [self.view addSubview:self.loadingView];
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        loadingView.center = CGPointMake(size.width / 2, (size.height - 20 - 44 * 2) / 2);
        [loadingView startAnimating];
    }
}

- (void)hideLoadingView {
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}

@end
