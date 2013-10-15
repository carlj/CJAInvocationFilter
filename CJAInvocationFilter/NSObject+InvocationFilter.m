//
//  NSObject+Invocation.m
//  CJAInvocation
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "NSObject+InvocationFilter.h"
#import <objc/objc-runtime.h>

static void *NSObjectAftersFiltersPropertyKey = &NSObjectAftersFiltersPropertyKey;
static void *NSObjectBeforeFilterFiltersPropertyKey = &NSObjectBeforeFilterFiltersPropertyKey;


@implementation NSObject (InvocationFilter)

+ (void)load {
  
  SEL tmpSelector = NSSelectorFromString(@"cja_forwarded:");
  Method newMethod = class_getInstanceMethod(self, tmpSelector);

  if (!newMethod) {
    
    [self swizzleMethod: @selector(forwardInvocation:) withMethod: @selector(cja_forwardInvocation:)];

    newMethod = class_getInstanceMethod(self, @selector(cja_forwardInvocation:));
    class_addMethod(self,
                    tmpSelector,
                    class_getMethodImplementation(self, tmpSelector),
                    method_getTypeEncoding(newMethod));

  }
  

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

- (void)removeFiltersForSelector:(SEL)selector {
  
  [self removeBeforeFilterForSelector: selector];
  [self removeAfterFilterForSelector: selector];
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
  
  NSString *filterKey = NSStringFromSelector(selector);
  
  if (!self.beforeFilters[filterKey] && !self.afterFilters[filterKey]) {
    
    NSString *swizzleSelectorString = [NSString stringWithFormat:@"cja_%@", NSStringFromSelector(selector)];
    SEL swizzleSelector = NSSelectorFromString(swizzleSelectorString);
    
    if (!class_getInstanceMethod(self.class, swizzleSelector)) {
      [self.class swizzleMethod: swizzleSelector withMethod: selector];
    }
    
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
