//
//  NSObject+Invocation.m
//  CJAInvocation
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "NSObject+Invocation.h"
#import <objc/objc-runtime.h>

static void *NSObjectProxyPropertyKey = &NSObjectProxyPropertyKey;

@interface CJAProxy ()

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, strong) NSMutableDictionary *beforeFilters;
@property (nonatomic, strong) NSMutableDictionary *afterFilters;

@end

@implementation CJAProxy

- (id)initWithTarget:(NSObject *)target {
  
  self = [super init];
  if (self) {
    
    self.target = target;
    self.beforeFilters = [NSMutableDictionary dictionary];
    self.afterFilters = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)setBeforeFilter:(CJAFilterBlock)filter forSelector:(SEL)selector {
  [self.beforeFilters setObject:filter forKey: NSStringFromSelector(selector)];
}

- (void)setAfterFilter:(CJAFilterBlock)filter forSelector:(SEL)selector {
  [self.afterFilters setObject:filter forKey: NSStringFromSelector(selector)];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
  
  NSMethodSignature* signature = [super methodSignatureForSelector: selector];
  if (!signature) {

    signature = [self.target methodSignatureForSelector:selector];
  }
  return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
  
  if (![self.target respondsToSelector: anInvocation.selector]) {
    [super forwardInvocation: anInvocation];
    return;
  }
  
  NSString *selectorString = NSStringFromSelector(anInvocation.selector);
  
  __weak typeof(NSObject) *weakTarget = self.target;
  CJAFilterBlock beforeFilter = self.beforeFilters[selectorString];
  if (beforeFilter) {
    beforeFilter(weakTarget);
  }
  
  [anInvocation invokeWithTarget: self.target];
  
  CJAFilterBlock afterFilter = self.afterFilters[selectorString];
  if (afterFilter) {
    afterFilter(weakTarget);
  }
  
}


@end

@implementation NSObject (Invocation)

- (CJAProxy *)proxy {
  
  CJAProxy *proxy = objc_getAssociatedObject(self, &NSObjectProxyPropertyKey);
  if (!proxy) {
    proxy = [[CJAProxy alloc] initWithTarget: self];
    objc_setAssociatedObject(self, &NSObjectProxyPropertyKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
  }
  
  return proxy;
}




@end
