//
//  DicTo.m
//  Runtime
//
//  Created by yulm on 16/3/3.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import "DicTo.h"
#import <objc/runtime.h>

static NSMutableDictionary *map = nil;
@implementation DicTo

+(void)load {
    map = [NSMutableDictionary new];
    map[@"name1"] = @"name";
    map[@"status1"]              = @"status";
    
    map[@"name2"]                = @"name";
    
    map[@"status2"]              = @"status";
    

}


@end
