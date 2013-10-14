//
//  ViewController.m
//  CJAInvocation
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import "ExampleViewController.h"
#import "NSObject+Invocation.h"

@interface TestObject : NSObject

- (void)doSomething;

@end

@implementation TestObject

- (void)doSomething {
  NSLog(@"1232 %s", __FUNCTION__);
}

@end

@interface ExampleViewController ()

@property (nonatomic, strong) TestObject *object;

@end

@implementation ExampleViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.object = [TestObject new];
  
  [self.object setBeforeFilter:^(NSObject *object){
    NSLog(@"before filter");
  }
                        forSelector:@selector(doSomething)];
  
  [self.object setAfterFilter:^(NSObject *object){
    NSLog(@"after filter");
  }
                        forSelector:@selector(doSomething)];
  
  
  [self.object doSomething];
  

  [self.object removeFiltersForSelector: @selector(doSomething)];
  [self.object doSomething];
 
}


@end
