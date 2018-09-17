#  Rxy - Pragmatic Rx unit testing

Rxy is a bunch of useful functions and classes that can help you to simplify testing of RxSwift based code. It's goal is to provide these features:

* A range of 'wait…' functions that wait for asynchronous RxSwift code to execute then add errors to Xcode's test report if the observable doesn't behave as expected or return the result.
* A range of support functions for building RxSwift based mocks which automatically execute asynchronously so that the mock's threading model matches the implementations.
* A simplified mock configuration model.
* *Significant* code reduction in unit tests.
* *Significant* code reduction in mock classes.

Rxy achieves this through 3 core architectural concepts:

* A set of __`waitFor*()`__ functions which use the RxBlocking framework to wait on asynchronous Rx calls then provide additional validation of results.
* A set of __`*Result`__ classes which provide centralised configuration of mock responses.
* A set of __`mockFunction(…)`__ functions which execute on background threads and post the requested results asynchronously on the main thread.

# Guide

## Demo project

If you open up the Rxy project in Xcode you'll see a target called __RxyDemoTests__. This target is a unit test target that demonstrates all the options that Rxy has to offer. In addition there are also a range of failing tests which show the sorts of errors Rxy produces.

## Mocking protocols

Often we need to mock out protocols that return Rx objects. So lets deep dive straight into this by looking at a mock for a typical backend service, then refactoring it to use Rxy. Here's the original mock class. It provides 3 functions from the `HTTPClient` protocol: `postCompletable(…)`, `getSingle(…)`, `doMaybe(…)` and `doObservable()`:

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

* The number of variables to provide all the different options for a response to a call.
* All the code required to trigger the correct response.
* The fact that it executes synchronously. 

Although not that important for most unit tests, this last point about synchronous execution has come in when a test has succeeded instead of failing because it was running synchronously instead of asynchronously.

For 3 functions, the mock has quite a bit of code. Now lets take a look at building this same mock with Rxy:

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

Considerably less code:

* Asynchronously execution! *(Ok - I thought that was important)* 
* Inherits from __`BaseMock`__ - technically this is not required, however `BaseMock` tracks the file and line number where the mock was instantiated, allowing it to place mocking errors in the unit test code. This helps with debugging because you don't have to goto the mocks to see the errors.
* Each function has just one __`*Result`__ property for defining how it responds. And if you name them consistantly (I recommend the practice of us 'Result' as a suffix) they'll be easy to find.
* All the boilerplate is remove and replaced with __`mockFunction(…)`__ calls that do all the dirty work.

Thats it. Thats all you need to do to your mocks.

### Partial mocks

Partial mocking is where we extend an established class and mock some of the functions on it. With partial mocks we cannot extend `BaseMock`, so we make use of the `AsyncMock` protocol to gain access to the same functionality `BaseMock` provides. Here's an example using a `NetworkHTTPClient` class instead of the `HTTPClient` protocol.

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

Yep, that's right. It looks exactly the same as using `BaseMock`. The only difference is that if the mock generates an error, Xcode will see it on the mock code.

However you can change that. `mockFunction(…)` has two arguments so you can pass the file and line where you want the error to be placed in Xcode (Take a look at the `BaseMock` code and you'll see how it uses those arguments). So you could define some variables in your mock and pass the file and line values through from the unit test if you want.

## Unit Testing

Now that we have the mocks in order, let's look at how we can slim down the tests. As with the mocking, let's look at some sources to see how Rxy can work with your tests. 

When testing RxSwift code developers often start by using __`subscribe(…)`__ to execute their Rx code. Excluding the test framework code (XCTest or Quick), here's a typical example:

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

This is also based on the none-Rxy mock `MockHTTPClient` and as you can see there's quite a bit of boilerplate code needed to run the test: the `subscribe(…)` call, the `callDone` variable, the Nimble `toEventually(…)`, the disposing code and the unexpected error reporting.

Digging in RxSwift a bit you'll find the __RxBlocking__ framework which can be used in tests to execute an asynchronous Rx call in a synchronous fashion. This can help tremendously like this:

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

That's certainly better, but now we're having to catch to report on errors. This is where Rxy comes in. It combines RxBlocking with additional error checking and Rxy's mocking to simply the test down to the minimum required: 

```swift
let mockHTTPClient = MockHTTPClient()
let remoteService = RemoteService(client: mockHTTPClient)

mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))

let response: RemoteCallResponse? = remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()
expect(self.mockHTTPClient.getSingleURL, line: line) == "xyz"
expect(response?.aValue, line: line) == "abc"
```

Compared to the original, that's considerable easier to write and read, and in case you didn't notice :-) It's also over half the size.

Rxy utilises 2 tricks in this code:

1. Setting a mock response via the `.value(…)` function.
2. Waiting for the Single to finish executing using the `waitForSuccess()` function. This also unwraps and returns the value from the single, and produces a test failure if it produces an error.

So writing tests with Rxy is really just doing 3 things: writing the mocks, setting values to return and waiting for the responses. Rxy really kicks in when your dealing with more complex examples of test code. For example here's a test that's going to take anyone a bit go study to figure out (And yes, this is based on a real example I found in some unit tests):

```swift
func testComplexRxSwiftCallsUsingSubscribe() {
        
    let disposeBag = DisposeBag()
    var callDone: Bool = false
    
    mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
    remoteService.makeSingleRemoteCall(toUrl: "xyz")
        .asObservable().concatMap { response -> Single<RemoteCallResponse> in
            expect(response.aValue) == "abc"
            self.mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "def")
            return self.remoteService.makeSingleRemoteCall(toUrl: "xyz")
        }
        .asObservable().concatMap { response -> Single<RemoteCallResponse> in
            expect(response.aValue) == "def"
            self.mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "ghi")
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

Ok, after a refactor, here's Rxy's version of the same test:

```swift
func testComplexRxSwiftCallsUsingRxy() {
        
    mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
    expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
        
    mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "def")
    expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "def"
        
    mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "ghi")
    expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "ghi"
}

```

Ta - Da!

# Reference

Lets take a look at the options and waits based on the available Rx types. Note: Rxy supports the `Observable`, `Completable`, `Single<>` and `Maybe<>` types. 

### Observables

#### Mock value options

`.generate generate(using: @escaping (AnyObserver<T>) -> Void)` - Returns an observable which uses the passed closure to generate its results. The closure is passed a reference to an observer so you can return results by using code like this:

```swift
    .generate { observable in
        observable.on(.next(5))
        observable.on(.completed)
    }
```

`.sequence(_ values: [Error]T])` - Returns an observable the values in the passed array individually returned from the observable.

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

