//
//  NSObject+Invocation.h
//  CJAInvocation
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CJAFilterBlock)(NSObject *object);

@interface NSObject (Invocation)

@property (nonatomic, strong, readonly) NSMutableDictionary *beforeFilters;
@property (nonatomic, strong, readonly) NSMutableDictionary *afterFilters;

- (void)setBeforeFilter:(CJAFilterBlock)filter forSelector:(SEL)selector;
- (void)setAfterFilter:(CJAFilterBlock)filter forSelector:(SEL)selector;

- (void)removeBeforeFilterForSelector:(SEL)selector;
- (void)removeAfterFilterForSelector:(SEL)selector;
- (void)removeFiltersForSelector:(SEL)selector;

@end
