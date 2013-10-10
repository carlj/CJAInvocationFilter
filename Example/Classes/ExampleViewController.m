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
  NSLog(@"%s", __FUNCTION__);
}

@end

@interface ExampleViewController ()

@property (nonatomic, strong) NSObject *object;

@end

@implementation ExampleViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.object = [TestObject new];
  [self.object.proxy setBeforeFilter:^(NSObject *object){
    NSLog(@"befor filter");
  }
                        forSelector:@selector(doSomething)];
  
  [self.object.proxy setAfterFilter:^(NSObject *object){
    NSLog(@"after filter");
  }
                        forSelector:@selector(doSomething)];
  
  
  [self.object.proxy doSomething];
}


@end
