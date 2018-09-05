#  Rxy - Pragmatic Rx unit testing

Rxy is a bunch of useful functions and classes that can help you to simplify testing of RxSwift based code.

## AsyncMock

AsyncMock is an extension that provides functions for asynchronously returning values from mocking that return RxSwift observables.  

When writing mocks for testing, developer usually write code like this:

```
class MyMock: AppProtocol {
    func doSomething() -> Single<AThing> {
        return .just(AThing())
    }
}
```

This executes synhronously and is easy to write, working in the majority of test cases, however there can be sitatuations where synchronous code like this will work in a test, but not work in the app because  
