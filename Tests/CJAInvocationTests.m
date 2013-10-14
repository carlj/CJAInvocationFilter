//
//  CJAInvocationTests.m
//  CJAInvocationTests
//
//  Created by Carl Jahn on 10.10.13.
//  Copyright (c) 2013 Carl Jahn. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+Invocation.h"

@interface TestCaseObject : NSObject

- (BOOL)doSomethingTest;

@end

@implementation TestCaseObject

- (BOOL)doSomethingTest {
  return YES;
}

@end

@interface CJAInvocationTests : XCTestCase

@property (nonatomic, strong) TestCaseObject *testObject;

@end

@implementation CJAInvocationTests

- (void)setUp {
  [super setUp];
  
  self.testObject = [TestCaseObject new];
}

- (void)tearDown {
  
  self.testObject = nil;
  
  [super tearDown];
}


- (void)testBothFilter{
  
  __block BOOL beforeFilterCalled = NO;
  [self.testObject setBeforeFilter:^(NSObject *object){
    beforeFilterCalled = YES;
  }
                       forSelector:@selector(doSomethingTest)];
  
  __block BOOL afterFilterCalled = NO;
  [self.testObject setAfterFilter:^(NSObject *object){
    afterFilterCalled = YES;
  }
                      forSelector:@selector(doSomethingTest)];
  
  BOOL result = [self.testObject doSomethingTest];
  
  XCTAssertTrue(result, @"method dont called");
  XCTAssertTrue(beforeFilterCalled, @"beforeFilter dont called");
  XCTAssertTrue(afterFilterCalled, @"afterFilter dont called");
}

- (void)testAfterFilter {
  
  __block BOOL beforeFilterCalled = NO;
  [self.testObject setBeforeFilter:^(NSObject *object){
    beforeFilterCalled = YES;
  }
                       forSelector:@selector(doSomethingTest)];
  
  
  BOOL result = [self.testObject doSomethingTest];
  
  XCTAssertTrue(result, @"method dont called");
  XCTAssertTrue(beforeFilterCalled, @"beforeFilter dont called");
}

- (void)testBeforeFilter {
  
  __block BOOL afterFilterCalled = NO;
  [self.testObject setAfterFilter:^(NSObject *object){
    afterFilterCalled = YES;
  }
                      forSelector:@selector(doSomethingTest)];
  
  
  BOOL result = [self.testObject doSomethingTest];
  
  XCTAssertTrue(result, @"method dont called");
  XCTAssertTrue(afterFilterCalled, @"afterFilter dont called");
}

- (void)testWrongSelector {
  
  BOOL result = NO;
  @try {
    [((id)self.testObject) testBothFilter];
  }
  @catch (NSException *exception) {
    result = YES;
  }
  
  XCTAssertTrue(result, @"method called");
}

@end
