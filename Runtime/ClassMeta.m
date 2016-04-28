//
//  ClassMeta.m
//  Runtime
//
//  Created by yulm on 16/3/2.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import "ClassMeta.h"
#import <objc/runtime.h>

@implementation ClassMeta

void MetaClass(id self, SEL _cmd) {
    NSLog(@"this object is %p", self);
    NSLog(@"Class is %@, super class is %@", [self class], [self superclass]);
    
    Class currentCls = [self class];
    for (NSInteger i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %ld times gives %p", i, currentCls);
        currentCls = objc_getClass((__bridge void *)currentCls);
    }
    
    NSLog(@"NSObject's class is %p", [NSObject class]);
    NSLog(@"NSObject's meta class is %p", objc_getClass((__bridge void *)[NSObject class]));
}

+ (void)ex_registerClassPair{
    Class newClass = objc_allocateClassPair([NSError class], "TestClass", 0);
    class_addMethod(newClass, @selector(MetaClass), (IMP)MetaClass, "v@:");
    objc_registerClassPair(newClass);
    
    id instance = [[newClass alloc]initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(MetaClass)];
}



@end
