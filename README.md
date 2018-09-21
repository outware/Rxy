#  Rxy - Pragmatic RxSwift unit testing

Rxy is a collection of useful functions and classes that can help you to simplify testing of RxSwift based code. It's core features are:

* 'wait…' functions that wait for asynchronous RxSwift code to execute before testing the results and adding errors to Xcode's test report if the results aren't as expected.
* Support functions for building RxSwift based mocks which execute asynchronously so that the mock's threading model matches your implementations.
* Simplified mock configuration models.
* *Significant* code reduction in unit tests.
* *Significant* code reduction in mock classes.

To achieve these goals, Rxy uses 3 core architectural concepts:

* A set of __`waitFor*()`__ functions which use the RxBlocking framework to wait on asynchronous Rx calls before providing additional validation of results.
* A set of __`*Result`__ classes which provide centralised configuration of mock responses.
* A set of __`mockFunction(…)`__ functions which execute on background threads and respond asynchronously on the main thread to simulate RxSwift's normal usage.

# Guide

## Demo project

Included in the Rxy Xcode project is a target called __RxyDemoTests__. This target demonstrates all the options that Rxy has to offer including a range of failing tests to show the errors Rxy generates.

## Mocking protocols

In unit testing we often we need to mock out protocols that return Rx objects. Writing these mocks can be time consuming and tedious. As an example, here's a mock for a typical backend service. It provides 4 functions which return RxSwift objects: `postCompletable(…)`, `getSingle(…)`, `doMaybe(…)` and `doObservable()`. First we'll look at the original mock, then we'll look at it after converting to Rxy:

```swift
class MockHTTPClientOldSchool: HTTPClient {
    
    var postCompletableURL: String?
    var postCompletableURLSuccess: Bool?
    var postCompletableURLError: Error?
    func postCompletable(url: String) -> Completable {
        postCompletableURL = url
        if let _ = postCompletableURLSuccess {
            return Completable.empty()
        }
        if let error = postCompletableURLError {
            return Completable.error(error)
        }
        fatalError("Unexpected method call")
    }
    
    var getSingleURL: String?
    var getSingleURLResult: RemoteCallResponse?
    var getSingleURLError: Error?
    func getSingle(url: String) -> Single<RemoteCallResponse> {
        getSingleURL = url
        if let result = getSingleURLResult {
            return Single.just(result)
        }
        if let error = getSingleURLError {
            return Single.error(error)
        }
        fatalError("Unexpected method call")
    }
    
    var doMaybeURL: String?
    var doMaybeURLComplete: Bool?
    var doMaybeURLResult: RemoteCallResponse?
    var doMaybeURLError: Error?
    func doMaybe(url: String) -> Maybe<RemoteCallResponse> {
        doMaybeURL = url
        if let result = doMaybeURLResult {
            return Maybe.just(result)
        }
        if let _ = doMaybeURLComplete {
            return Maybe.empty()
        }
        if let error = doMaybeURLError {
            return Maybe.error(error)
        }
        fatalError("Unexpected method call")
    }

    var doObservableResults: [Int]?
    var doObservableError: Error?
    func doObservable() -> Observable<Int> {
        guard doObservableResults != nil || doObservableError != nil else {
            fatalError("Unexpected method call")
        }
        return Observable<Int>.create { observable in
            if let results = self.doObservableResults {
                results.forEach { observable.on(.next($0)) }
                observable.on(.completed)
            }
            if let error = self.doObservableError {
                observable.on(.error(error))
            }
            return Disposables.create()
        }
    }
}
``` 

There are several things of interest in this code:

* The number of variables to provide all the different options for a response.
* The amount of code required to trigger the correct response.
* That the code executes synchronously. 
* Lots of code that will have to be cut-n-pasted across other mock implementations.

Although not that important for a lot of unit tests, running synchronously in some situations can cause unit tests to pass when they should fail. For example where a synchronous function is using an asynchronous call internally and not waiting for its results. If the tests are written using synchronous mocks, the tests may pass where the code will fail in production. 

So we have lots of variables and boilerplate, synchronous execution and ultimately an increasing tech debt to main. 

Now lets take a look at this same mock written using Rxy:

```swift
class MockHTTPClientRxy: BaseMock, HTTPClient {
    
    var postCompletableURL: String?
    var postCompletableURLResult: CompletableResult?
    func postCompletable(url: String) -> Completable {
        postCompletableURL = url
        return mockFunction(returning: postCompletableURLResult)
    }
    
    var getSingleURL: String?
    var getSingleURLResult: SingleResult<RemoteCallResponse>?
    func getSingle(url: String) -> Single<RemoteCallResponse> {
        getSingleURL = url
        return mockFunction(returning: getSingleURLResult)
    }
    
    var doMaybeURL: String?
    var doMaybeURLResult: MaybeResult<RemoteCallResponse>?
    func doMaybe(url: String) -> Maybe<RemoteCallResponse> {
        doMaybeURL = url
        return mockFunction(returning: doMaybeURLResult)
    }

    var doObservableResults: ObservableResult<Int>?
    func doObservable() -> Observable<Int> {
        return mockFunction(returning: doObservableResults)
    }
}
``` 

Considerably less code, here's the core features:

* Asynchronously execution! 
* Inherits from __`BaseMock`__ - technically this not required, but `BaseMock` tracks the file and line number where the mock was instantiated and passes them automatically to the `mockFunction(…)` calls. This lets Rxy place mocking errors back in the unit test which is much better than trolling the mocks to see generated errors.
* Just one __`*Result`__ property for defining how each function responds. 
* No boilerplate. The __`mockFunction(…)`__ calls do all the dirty work.

Thats it. Simples.

### Partial mocks

Sometimes we can't use `BaseMock`. When partial mocking for example. In those sorts of cases we can still use Rxy by adding the `AsyncMock` protocol to gain access to Rxy's `mockFunction(…)` function calls. Here's an example using a `NetworkHTTPClient` class instead of the `HTTPClient` protocol.

```swift
class HTTPMock: NetworkHTTPClient, AsyncMock {

    var getSingleURL: String?
    var getSingleURLResult: SingleResult<RemoteCallResponse>?
    func getSingle(url: String) -> Single<RemoteCallResponse> {
        getSingleURL = url
        return mockFunction(returning: getSingleURLResult)
    }
}
```

Yep, that's right. It looks exactly the same as using `BaseMock`. The only difference is that if the mock generates an error, Xcode will place it in this code instead of the unit test.

But you can change that too. `mockFunction(…)` has two arguments which tell it the file and line where you want errors to be placed (Take a look at the `BaseMock` code and you'll see how it uses those arguments). So you set these arguments to some location that makes more sense if you like.

## Unit Testing

Now that we have the mocks in order, let's look at how we can slim down the tests. As with the mocking, let's look at how Rxy can improve your unit test code. Again we'll start with how it was done and work towards using Rxy.

When testing RxSwift code developers often start by using __`subscribe(…)`__ to execute their Rx code. Excluding the surrounding test framework code (XCTest or Quick), here's a typical example:

```swift
let mockHTTPClient = MockHTTPClient()
let remoteService = RemoteService(client: mockHTTPClient)

mockHTTPClient.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        
let disposeBag = DisposeBag()
var callDone: Bool = false
var response: RemoteCallResponse?
remoteService.makeSingleRemoteCall(toUrl: "xyz")
    .subscribe(
        onSuccess: { result in
            response = result
            callDone = true
    },
        onError: { error in
            fail("Unexpected error \(error)")
            callDone = true
    }).disposed(by: disposeBag)
        
expect(callDone).toEventually(beTrue())
expect(self.mockHTTPClient.getSingleURL, line: line) == "xyz"
expect(response?.aValue, line: line) == "abc"

```

This is based on the none-Rxy `MockHTTPClient` and as you can see there's quite a bit of boilerplate code needed to run the test. The `subscribe(…)` call, the `callDone` variable, a Nimble `toEventually(…)`, all the dispose related code  and the unexpected error reporting.

RxSwift does provide a testing framework that can help simplfy this called __RxBlocking__ which helps with asynchronous Rx calls in unit tests:

```swift
let mockHTTPClient = MockHTTPClient()
let remoteService = RemoteService(client: mockHTTPClient)

mockHTTPClient.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        
do {
    let response: RemoteCallResponse? = try remoteService.makeSingleRemoteCall(toUrl: "xyz").toBlocking().first()
    expect(self.mockHTTPClient.getSingleURL, line: line) == "xyz"
    expect(response?.aValue, line: line) == "abc"
}
catch let error {
    fail("Unexpected error \(error)")
}
```

It's certainly better, but we still have to deal with errors. Rxy goes one step beyond this, combining RxBlocking with additional error checking in it's `waitfFor…(…)` functions and it's mocking code to remove everything except the bare essentials of your test: 

```swift
let mockHTTPClient = MockHTTPClient()
let remoteService = RemoteService(client: mockHTTPClient)

mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))

let response: RemoteCallResponse? = remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()
expect(self.mockHTTPClient.getSingleURL, line: line) == "xyz"
expect(response?.aValue, line: line) == "abc"
```

Compared to the original, it's considerable easier to read and write, and in case you didn't notice :-) It's also over half the size.

So writing tests with Rxy is really just a matter of doing 2 things: 

* Simplifying your mocks.
* Utilising the `waitFor…(…)` function to wait for the asynchronous code to finish. 

### A complex example

Rxy's power can be really seen when dealing with complex unit tests. Here's an example that's going to take anyone a bit of study to figure out (And yes, this is based on a real example I found in some unit tests):

```swift
func testComplexRxSwiftCallsUsingSubscribe() {
        
    let disposeBag = DisposeBag()
    var callDone: Bool = false
    
    mockHTTPClientl.getSingleURLResult = RemoteCallResponse(aValue: "abc")
    remoteService.makeSingleRemoteCall(toUrl: "xyz")
        .asObservable().concatMap { response -> Single<RemoteCallResponse> in
            expect(response.aValue) == "abc"
            self.mockHTTPClient.getSingleURLResult = RemoteCallResponse(aValue: "def")
            return self.remoteService.makeSingleRemoteCall(toUrl: "xyz")
        }
        .asObservable().concatMap { response -> Single<RemoteCallResponse> in
            expect(response.aValue) == "def"
            self.mockHTTPClient.getSingleURLResult = RemoteCallResponse(aValue: "ghi")
            return self.remoteService.makeSingleRemoteCall(toUrl: "xyz")
        }.asSingle()
        .subscribe(
            onSuccess: { response in
                expect(response.aValue) == "ghi"
                callDone = true
        },
            onError: { error in
                fail("Unexpected error \(error)")
                callDone = true
        }).disposed(by: disposeBag)
      
    expect(callDone).toEventually(beTrue())
}
```

After a refactor - here's Rxy's version:

```swift
func testComplexRxSwiftCallsUsingRxy() {
        
    mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))
    expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
        
    mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "def"))
    expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "def"
        
    mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "ghi"))
    expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "ghi"
}

```

Ta - Da!

# Reference

Lets take a look at the options and waits based on the available Rx types. Note: Rxy supports the `Observable`, `Completable`, `Single<>` and `Maybe<>` types. 

### Observables

#### Mock value options

`.generate(using: @escaping (AnyObserver<T>) -> Void)` - Returns an observable which uses the passed closure to generate results like this:

```swift
    thingResult = .generate { observable in
        observable.on(.next(5))
        observable.on(.completed)
    }
```

`.sequence(_ values: [T])` - Returns an observable with the passed array returned as individual values followed by a completion.

`.throw(_ error: Error)` - Returns an observable with the error.

#### Waits

`.waitForCompletion() -> [T]` - Waits until the observable completes. Generates a test failure on this line if the completable produces an error. Returns the values returned by the Observable.

`.waitForError() -> (error: Error, values: [T])` - Waits until the completable produces an error. Generates a test failure on this line if the completable completes instead. Returns a tuple containing both the error and any returned values.

### Completables

#### Mock value options

`.completed()` - Returns a completed completable.

`.throw(_ error: Error)` - Returns a completable with the error.

#### Waits

`.waitForCompletion()` - Waits until the completable completes. Generates a test failure on this line if the completable produces an error. 

`.waitForError() -> Error?` - Waits until the completable produces an error. Generates a test failure on this line if the completable completes instead.

### Singles

#### Mock value options

`.value(_ value: T)` - Returns the passed value as the result of the single. 

`.value(_ value: () -> T)` - Returns the result of executing the passed closure as the result of the single. 

`.value(_ json: String)` - Decodes the passed JSON string into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.value(_ jsonFromFile: String, extension: String?, inBundleWithClass: AnyClass)` - Loads JSON from a file in a bundle and decodes it into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.throw(_ error: Error)` - Returns a single with the error.

#### Waits

`.waitForSuccess() -> T?` - Waits until the single completes. Generates a test failure on this line if the single produces an error or if another error occurs such as a JSON value being incorrect. Returns the value produced by the Single.

`.waitForError() -> Error?` - Waits until the single produces an error. Generates a test failure on this line if the single completes instead.

### Maybes

#### Mock value options

`.completed()` - Returns a completed maybe.

`.value(_ value: T)` - Returns the passed value as the result of the maybe. 

`.value(_ value: () -> T)` - Returns the result of executing the passed closure as the result of the maybe. 

`.value(_ json: String)` - Decodes the passed JSON string into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.value(_ jsonFromFile: String, extension: String?, inBundleWithClass: AnyClass)` - Loads JSON from a file in a bundle and decodes it into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.throw(_ error: Error)` - Returns a maybe with the error.

#### Waits

`.waitForCompletion()` - Waits until the maybe completes. Generates a test failure on this line if the maybe produces an error or if it produces a value instead of completing.

`.waitForValue() -> T?` - Waits until the maybe produces a value. Generates a test failure on this line if the maybe produces an error or if it completes instead.

`.waitForError() -> Error?` - Waits until the maybe produces an error. Generates a test failure on this line if the maybe completes instead.

# Installation via Carthage

Add this to your **Cartfile.private** file:

```swiftq
github "outware/Rxy"
```

