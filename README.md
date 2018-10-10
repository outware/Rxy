#  Rxy - Pragmatic RxSwift unit testing

Version 0.4.0

A collection of useful functions and classes that can simplify testing of RxSwift code. 

 * [Guide](#guide)
    * [Demo project][demoproject]
    * [Mocking protocols][mockingprotocols]
    * [Unit Testing][unittesting]
 * [Reference][reference]
 * [Installation][installation]

#### Features:

* 'wait…' functions that wait for asynchronous RxSwift code to execute before testing the results and adding errors to Xcode's test report if the results aren't as expected.
* Support functions for building RxSwift based mocks which execute asynchronously so that the mock's threading model matches your implementations.
* Simplified mock configuration models.
* *Significant* code reduction in unit tests.
* *Significant* code reduction in mock classes.

To achieve this, Rxy uses 3 core things:

* __`waitFor*()`__ functions which wait on asynchronous Rx calls, then validate the results.
* __`*Result`__ classes which provide centralised configuration of mock responses.
* __`mockFunction(…)`__ functions which execute asynchronously in the background to simulate RxSwift functionality.

# Guide

## Demo project

If you checkout the Rxy project, you will find an Xcode target called __RxyDemoTests__. This target demonstrates all the options that Rxy offers including a range of failing tests to show Rxy's built in validations.

## Mocking protocols

In unit testing we often we need to mock out protocols which return Rx objects. Writing these mocks can be time consuming and tedious and lead to a lot of cut-n-pasted code.

As an example, lets look at a mock for a typical backend service. It provides 4 functions returning RxSwift objects: `postCompletable(…)`, `getSingle(…)`, `doMaybe(…)` and `doObservable()`. 

First we'll look at the original mock as it might be coded in a test suite, then we'll convert it to use Rxy:

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

Points of interest:

* Each function requires different variables to define the different results.
* Each implementation has to include code to decide which result to produce or to fail the call.
* All this code executes synchronously. 
* A lot less code.

Synchronicity is not important in a lot of unit tests, however in some situations mocks written synchronously can cause unit tests to pass when they should fail. For example where a function is using an asynchronous call internally and not waiting correctly for its results. If the mocks are synchronous, the tests may pass even though the code fails in production. 

The summary is that this mock has a lot of variables and synchronous boilerplate code which which almost always ends up being cut-n-pasted to other mocks, resulting in an increasing tech debt to maintain.

Rxy's goal is to solve these problems and reduce the tech debt. Here's the Rxy version of the same mock:

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

Comparing the two:

* Only one variable required define a function's result.
* Only one line to execute the function asynchronously and return the correct result.
* Much, much easier to read and understand.

Whilst not technically required, Rxy's version Inherits from __`BaseMock`__ is useful because it allows Rxy to automatically place mock related errors (such as unexpected method call errors) back in the unit test where the mock was created. This puts them as close as possible to the failing tests and helps with debugging.

Other than that, all that you have to remember to create a mock is: inherit from `BaseMock`, create a 'Result' variable, and call `mockFunction(…)`. Simple and easy.

### Partial mocks

Sometimes we can't use `BaseMock`. When partial mocking for example. In these sorts of cases we can still use Rxy by adding the `AsyncMock` protocol to gain access to Rxy's `mockFunction(…)` calls. Here's an example where we are partially mocking a `NetworkHTTPClient` class instead of the `HTTPClient` protocol.

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

Yep, that's right. It looks exactly the same as using a `BaseMock`. The only difference is when executing, if an error is generated it will be placed on the `mockFunction(…)` line in the mock instead of the unit test.

But you can change that too. `mockFunction(…)` has two arguments which tell it the file and line where you want errors to be placed (Take a look at the `BaseMock` code and you'll see how easy it can be done). So if you if you know where you want to errors to occur, just set these two arguments.

## Unit Testing

Now let's look at how we can slim down your unit tests. Again we'll start with how it's commonly done and then show how Rxy can make life easier.

When testing RxSwift code developers often start by using __`subscribe(…)`__ to execute the functions. Excluding the surrounding test framework (XCTest or Quick), here's a typical example:

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

This is using the original `MockHTTPClient` mock and apart from that, there's quite a bit of boilerplate code needed to run the test. The `subscribe(…)` call itself, the `callDone` variable to track when it's finished, a Nimble `toEventually(…)` to wait for the to finish, all the dispose related code and finally the unexpected error reporting. Thats actually quite a bit of code and once you start writing a lot of tests you'll find yourself cutting and pasting a lot.

To be fair, RxSwift does provide a testing framework that can help simplify this. It's called __RxBlocking__ and is designed to turn asynchronous Rx calls into synchronous calls. Here's our test re0written to use it:

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

It's certainly better, but we still have a fear amount of boiler plate and error checking code. 

Rxy goes one step beyond this, combining RxBlocking with additional error checking in it's `waitfFor…(…)` functions to remove everything except the bare essentials of your test. Combining that with Rxy based mocks and you'll end up with this: 

```swift
let mockHTTPClient = MockHTTPClient()
let remoteService = RemoteService(client: mockHTTPClient)

mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))

let response: RemoteCallResponse? = remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()
expect(self.mockHTTPClient.getSingleURL, line: line) == "xyz"
expect(response?.aValue, line: line) == "abc"
```

Compared to the original, it's considerable easier to read and write, and in case you didn't notice :-) It's also over half the size. 

Notice we now have to ability to tell the mock what we want to respond with using the `.value(…)` function, and all the error catching code is gone, as are the RxBlocking calls.

If we wanted our mock to return a `Single<T>` with an error, we could code the mock setting like this:

```swift
mockHTTPClient.getSingleURLResult = .throw(TestError.anError)
```

ie. Any and all options for what a mock can return are set on the same variable.

So to summarise: Using Rxy significantly simplifies your mocks, and significantly simplifies your unit tests.

### A complex example

Before we finish with this, lets look at a more complex test. I actually found code like like this in a real life test suite so it's a good example of just how much Rxy can simplify testing RxSwift based code. I've changed the names to protect the innocent, but as you can see, it would take anyone some time to figure out what this test does. It certainly took me some time and I had some written comments to help.

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

Figured it out? What it's doing is sending a series of calls to an API, changing the mocked response for each one, then checking the final result.

Not the greatest. Here's Rxy's version of the same test:

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

Lets take a look at the options Rxy provides for each of the available Rx types: `Observable<T>`, `Completable`, `Single<T>` and `Maybe<T>`. For each one I'll first list the functions that define the available result for the mocks, then the available wait functions you can use to wait and validate.

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

# Installation

## Carthage

Add this to your **Cartfile.private** file:

```swiftq
github "outware/Rxy"
```

