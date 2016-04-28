//
//  VaList.h
//  Runtime
//
//  Created by yulm on 16/4/21.
//  Copyright © 2016年 fengbangshou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VaList : NSMutableArray
+ (instancetype)arrWithObjs:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (void)testArr;
@property (nonatomic, copy) NSArray<NSString *> *arr;

@end
