//
//  CJAInvocationTests.m
//  CJAInvocationTests
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+InvocationFilter.h"

@interface TestObject : NSObject

- (BOOL)doSomething;

@end

@implementation TestObject

- (BOOL)doSomething {
  return YES;
}

@end

@interface CJAInvocationTests : XCTestCase

@property (nonatomic, strong) TestObject *testObject;

@end

@implementation CJAInvocationTests

- (void)setUp {
  [super setUp];
  
  self.testObject = [TestObject new];
}

- (void)tearDown {

  self.testObject = nil;
  
  [super tearDown];
}

- (void)testBeforeFilter {
  
  __block BOOL beforeFilterCalled = NO;
  [self.testObject.proxy setBeforeFilter:^(NSObject *object){
    beforeFilterCalled = YES;
  }
                         forSelector:@selector(doSomething)];
  
  __block BOOL afterFilterCalled = NO;
  [self.testObject.proxy setAfterFilter:^(NSObject *object){
    afterFilterCalled = YES;
  }
                        forSelector:@selector(doSomething)];
  
  
  BOOL result = [self.testObject.proxy doSomething];
  
  XCTAssertTrue(result, @"method dont called");
  XCTAssertTrue(beforeFilterCalled, @"beforeFilter dont called");
  XCTAssertTrue(afterFilterCalled, @"afterFilter dont called");
}

- (void)testAfterFilter {
  
  __block BOOL beforeFilterCalled = NO;
  [self.testObject.proxy setBeforeFilter:^(NSObject *object){
    beforeFilterCalled = YES;
  }
                             forSelector:@selector(doSomething)];
  
  
  BOOL result = [self.testObject.proxy doSomething];
  
  XCTAssertTrue(result, @"method dont called");
  XCTAssertTrue(beforeFilterCalled, @"beforeFilter dont called");
  
}

- (void)testBothFilter {
  
  __block BOOL afterFilterCalled = NO;
  [self.testObject.proxy setAfterFilter:^(NSObject *object){
    afterFilterCalled = YES;
  }
                            forSelector:@selector(doSomething)];
  
  
  BOOL result = [self.testObject.proxy doSomething];
  
  XCTAssertTrue(result, @"method dont called");
  XCTAssertTrue(afterFilterCalled, @"afterFilter dont called");
}

- (void)testWrongSelector {
  
  BOOL result = NO;
  @try {
    [self.testObject.proxy testBothFilter];
  }
  @catch (NSException *exception) {
    result = YES;
  }

  
  XCTAssertTrue(result, @"method called");
}

@end
