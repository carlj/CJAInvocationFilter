#CJAInvocationFilter
The category adapts the [before and after filter concept from Rails](http://guides.rubyonrails.org/action_controller_overview.html#filters). 

[![Build Status](https://travis-ci.org/carlj/CJAInvocationFilter.png?branch=master)](https://travis-ci.org/carlj/CJAInvocationFilter)
[![Coverage Status](https://coveralls.io/repos/carlj/CJAInvocationFilter/badge.png?branch=master)](https://coveralls.io/r/carlj/CJAInvocationFilter?branch=master)

##Installation
Just drag & drop the [`NSObject+InvocationFilter.h`](CJAInvocationFilter/NSObject+InvocationFilter.h) and [`NSObject+InvocationFilter.m`](CJAInvocationFilter/NSObject+InvocationFilter.m) to your project.

##Example
First of all take a look at the [Example Project](Example/Classes/ExampleViewController.m)

##Usage
``` objc
//import the category
#import "NSObject+InvocationFilter.h"
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
[self.object setBeforeFilter: ^(NSObject *object){
	NSLog(@"before filter");
}
                       forSelector: @selector(doSomething)];

[self.object setAfterFilter: ^(NSObject *object){
	NSLog(@"after filter");
}
                      forSelector: @selector(doSomething)];


//call the original method on the proxy
[self.object doSomething];
```

##Note
You cannot call methods that are implemented in the [NSObject Protocol](https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/Protocols/NSObject_Protocol/Reference/NSObject.html) e.g. class, hash, superclass, description and so on.

##LICENSE
Released under the [MIT LICENSE](LICENSE)
