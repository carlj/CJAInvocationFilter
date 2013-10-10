#CJAInvocation
The category adapts the [before and after filter concept from Rails](http://guides.rubyonrails.org/action_controller_overview.html#filters). 

[![Build Status](https://travis-ci.org/carlj/CJAInvocation.png?branch=master)](https://travis-ci.org/carlj/CJAInvocation)
[![Coverage Status](https://coveralls.io/repos/carlj/CJAInvocation/badge.png?branch=master)](https://coveralls.io/r/carlj/CJAInvocation?branch=master)

##Installation
Just drag & drop the [`CJAInvocation.h`](CJAInvocation/CJAInvocation.h) and [`CJAInvocation.m`](CJAInvocation/CJAInvocation.m) to your project.

##Example
First of all take a look at the [Example Project](Example/Classes/ExampleViewController.m)

##Usage
``` objc
//import the category
#import "NSObject+Invocation.h"
```

``` objc
//Create or use your custom class
@interface TestObject : NSObject

- (void)doSomething;

@end

@implementation TestObject

- (void)doSomething {
  NSLog(@"%s", __FUNCTION__);
}

@end
```

``` objc
TestObject *object = [TestObject new];

//add the filters to the proxy object
[self.object.proxy setBeforeFilter: ^(NSObject *object){
	NSLog(@"before filter");
}
                       forSelector: @selector(doSomething)];

[self.object.proxy setAfterFilter: ^(NSObject *object){
	NSLog(@"after filter");
}
                      forSelector: @selector(doSomething)];


//call the original method on the proxy
[self.object.proxy doSomething];
```

##Note
You cannot use default methods from the classes e.g. description.

##LICENSE
Released under the [MIT LICENSE](LICENSE)
