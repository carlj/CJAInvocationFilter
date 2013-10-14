//
//  NSObject+Invocation.m
//  CJAInvocation
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "NSObject+Invocation.h"
#import <objc/objc-runtime.h>

static void *NSObjectAftersFiltersPropertyKey = &NSObjectAftersFiltersPropertyKey;
static void *NSObjectBeforeFilterFiltersPropertyKey = &NSObjectBeforeFilterFiltersPropertyKey;


@implementation NSObject (Invocation)

+ (void)load {

  [self.class swizzleMethod: @selector(forwardInvocation:) withMethod: @selector(cja_forwardInvocation:)];
}

+ (BOOL)swizzleMethod:(SEL)currentSelector withMethod:(SEL)newSelector {
  
  Method currentMethod = class_getInstanceMethod(self, currentSelector);
  
  Method newMethod = class_getInstanceMethod(self, newSelector);
  
  BOOL result = class_addMethod(self,
                                currentSelector,
                                class_getMethodImplementation(self, currentSelector),
                                method_getTypeEncoding(currentMethod));
  result =	class_addMethod(self,
                            newSelector,
                            class_getMethodImplementation(self, newSelector),
                            method_getTypeEncoding(newMethod));
  
	method_exchangeImplementations( class_getInstanceMethod(self, currentSelector), class_getInstanceMethod(self, newSelector) );
	
  return YES;
}

- (NSMutableDictionary *)beforeFilters {
  
  NSMutableDictionary *beforeFilters = objc_getAssociatedObject(self, &NSObjectBeforeFilterFiltersPropertyKey);
  if (!beforeFilters) {
    beforeFilters = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &NSObjectBeforeFilterFiltersPropertyKey, beforeFilters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
  }
  
  return beforeFilters;
}

- (NSMutableDictionary *)afterFilters {
  
  NSMutableDictionary *afterFilters = objc_getAssociatedObject(self, &NSObjectAftersFiltersPropertyKey);
  if (!afterFilters) {
    afterFilters = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &NSObjectAftersFiltersPropertyKey, afterFilters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
  }
  
  return afterFilters;
}

- (void)setBeforeFilter:(CJAFilterBlock)filter forSelector:(SEL)selector {
  
  [self swizzleMethodsForSelector: selector];

  [self.beforeFilters setObject:filter forKey: NSStringFromSelector(selector)];
}

- (void)setAfterFilter:(CJAFilterBlock)filter forSelector:(SEL)selector {

  [self swizzleMethodsForSelector: selector];

  [self.afterFilters setObject:filter forKey: NSStringFromSelector(selector)];
}

- (void)removeBeforeFilterForSelector:(SEL)selector {
  
  [self.beforeFilters removeObjectForKey: NSStringFromSelector(selector)];
  
  [self swizzleMethodsForSelector: selector];
}

- (void)removeAfterFilterForSelector:(SEL)selector {
  
  [self.afterFilters removeObjectForKey: NSStringFromSelector(selector)];
  
  [self swizzleMethodsForSelector: selector];
}

- (void)swizzleMethodsForSelector:(SEL)selector {

  NSString *selectorString = [NSString stringWithFormat:@"cja_%@", NSStringFromSelector(selector)];
  
  if (!self.beforeFilters[NSStringFromSelector(selector)] && !self.afterFilters[NSStringFromSelector(selector)]) {
    [self.class swizzleMethod: NSSelectorFromString(selectorString) withMethod: selector];
  }

}


- (void)cja_forwardInvocation:(NSInvocation *)anInvocation {

  NSString *selectorString = NSStringFromSelector(anInvocation.selector);
  if (![selectorString hasPrefix: @"cja_"]) {
    NSString *tmpSelectorString = [@"cja_" stringByAppendingString: selectorString ];
    
    anInvocation.selector = NSSelectorFromString(tmpSelectorString);
  }
  
  
  if (![self respondsToSelector: anInvocation.selector]) {
    return;
  }
  
  __weak typeof(NSObject) *weakTarget = self;
  CJAFilterBlock beforeFilter = self.beforeFilters[selectorString];
  if (beforeFilter) {
    beforeFilter(weakTarget);
  }

  [anInvocation invoke];
  
  CJAFilterBlock afterFilter = self.afterFilters[selectorString];
  if (afterFilter) {
    afterFilter(weakTarget);
  }
  
}

@end
