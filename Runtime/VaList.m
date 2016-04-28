//
//  VaList.m
//  Runtime
//
//  Created by yulm on 16/4/21.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import "VaList.h"

@implementation VaList

+ (instancetype)arrWithObjs:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION{
    //#define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel(0,1)))
    //attribut(sentinel)告诉编译器，需要一个结尾的参数，告诉编译器参数的列表已经到最后一个不要再继续执行下去了
    NSMutableArray *arrs = [NSMutableArray array];
    
    //va_list是在C语言中解决变参的一组宏
    va_list argList;
    if (firstObj) {
        [arrs addObject:firstObj];
        
        //va_start宏，获取可变参数列表的第一个参数的地址
        //在这里是获取firstObj的内存地址，这时候argList的指针指向firstObj
        va_start(argList, firstObj);
        //临时指针变量
        id tmp;
        //va_arg宏，获取可变参数的当前参数，返回指定类型，并将指针指向下一参数
        //首先argList的内存地址指向firstObj，将对应存储的值取出，如果不为nil则判断为真，将取出的值放在数组，并且将指针指向下一个参数，这样每次循环argList所代表的指针偏移量就不断下移直到取出nil
        while ((tmp = va_arg(argList, id))) {
            [arrs addObject:tmp];
            NSLog(@"%@", arrs);
        }
        va_end(argList);
    }
    return (id)arrs;
}

- (void)testArr {
    if (!_arr) {
//        _arr = [NSArray array];
        _arr = @[@4, @3];
    }
    NSArray *arr1 = @[@1, @2];
    _arr = [_arr arrayByAddingObjectsFromArray:arr1];
    NSLog(@"v:%@", _arr);
    NSArray *arr2 = @[@"sd", @"23"];
    _arr = [_arr arrayByAddingObjectsFromArray:arr2];
    NSLog(@"v:%@", _arr);
}

@end
