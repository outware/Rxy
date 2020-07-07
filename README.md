#  Rxy - Pragmatic RxSwift unit testing

Version 0.4.0

A collection of useful functions and classes that can simplify testing of RxSwift code. 

**Features:**

* 'wait…' functions that wait for asynchronous RxSwift code to execute before testing the results and adding errors to Xcode's test report if the results aren't as expected.
* Support functions for building RxSwift based mocks which execute asynchronously so that the mock's threading model matches your implementations.
* Simplified mock configuration models.
* *Significant* code reduction in unit tests.
* *Significant* code reduction in mock classes.

To achieve this, Rxy uses 3 core things:

* __`waitFor*()`__ functions which wait on the asynchronous Rx calls, then validate the results.
* __`*Result`__ classes which provide centralised configuration of mock responses.
* __`mockFunction(…)`__ functions which execute asynchronously in the background to simulate RxSwift functionality.

Table of Contents
=================

   * [Rxy - Pragmatic RxSwift unit testing](#rxy---pragmatic-rxswift-unit-testing)
   * [Table of Contents](#table-of-contents)
   * [Guide](#guide)
      * [Demo project](#demo-project)
      * [Mocking protocols](#mocking-protocols)
         * [Partial mocks](#partial-mocks)
      * [Unit Testing](#unit-testing)
         * [A complex example](#a-complex-example)
   * [Reference](#reference)
      * [Observables](#observables)
         * [Mock value options](#mock-value-options)
         * [Waits](#waits)
      * [Completables](#completables)
         * [Mock value options](#mock-value-options-1)
         * [Waits](#waits-1)
      * [Singles](#singles)
         * [Mock value options](#mock-value-options-2)
         * [Waits](#waits-2)
      * [Maybes](#maybes)
         * [Mock value options](#mock-value-options-3)
         * [Waits](#waits-3)
   * [Installation](#installation)
      * [Carthage](#carthage)

# Guide

## Demo project

If you checkout the Rxy project, you will find an Xcode target called __RxyDemoTests__. This target demonstrates all the options that Rxy offers including a range of failing tests to show Rxy's built in validations.

## Mocking protocols

In unit testing we often we need to mock out protocols which return Rx objects. Writing these mocks can be time consuming and tedious and lead to a lot of cut-n-pasted code.

As an example, let's look at a mock for a typical backend service that mocks 4 protocol functions written using RxSwift: `postCompletable(…)`, `getSingle(…)`, `doMaybe(…)` and `doObservable()`. First here's the mock as it might be coded in a test suite:

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

* Each function requires multiple variables to define different results.
* Each implementation has to include code to decide which result to produce or to fail the call.
* All this code executes synchronously. 

Whilst synchronicity can be ignored in a lot of unit tests in some it can cause unit tests to pass when they should fail. For example where the implementation is using an asynchronous call internally and not waiting for the results. If the mocks are synchronous, the tests may pass even though the code fails in production. 

The summary is that this mock has a lot of variables, synchronous boilerplate code and a potentially flawed implementation which will almost certainly end up being cut-n-pasted to other mocks, resulting in a considerable amount of tech debt to maintain.

Rxy solves these problems and as a result, reduces the tech debt. Here's it's version of the same mock:

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
* Only one line to execute the function *asynchronously* and return the correct result.
* Shorter and easier to read and maintain.

Whilst not technically required, inheriting from __`BaseMock`__ is useful because it allows Rxy to automatically place mock related errors (such as unexpected method calls) in the unit test where the mock was created. Thus making it easier to figure out what went wrong when executing large test suites.

Other than that, all that you have to remember to create a Rxy mock is: 

1. Inherit from `BaseMock` (Optional).
2. Create a 'Result' variable.
3. Call `mockFunction(…)`.

### Partial mocks

Sometimes we can't use `BaseMock`. In partial mocking situations for example. In these cases Rxy can still be applied by adding the `AsyncMock` protocol to gain access to it's `mockFunction(…)` calls. Here's an example of partially mocking a `NetworkHTTPClient` class instead of the `HTTPClient` protocol.

```swift
class MockNetworkHTTPClient: NetworkHTTPClient, AsyncMock {

    var getSingleURL: String?
    var getSingleURLResult: SingleResult<RemoteCallResponse>?
    override func getSingle(url: String) -> Single<RemoteCallResponse> {
        getSingleURL = url
        return mockFunction(returning: getSingleURLResult)
    }
}
```

It looks exactly the same as a full mock implementation of a protocol. The only difference is when executing, if an error is generated it will be placed on the `mockFunction(…)` line instead of the unit test.

_Note: `mockFunction(…)` has two arguments which tell it the file and line where you want errors to be placed (Take a look at the `BaseMock` code) so if you if you know where you want to errors to occur, you can just set these two arguments._

## Unit Testing

Now let's look at how we can slim down your unit tests. Again we'll start with how it's commonly done and then show how Rxy can make life easier.

When testing RxSwift code developers often start by using __`subscribe(…)`__ to execute the functions. Excluding the surrounding test framework (usually XCTest or Quick) here's a typical example:

```swift
let mockHTTPClient = MockHTTPClientRxy()
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

Even though we're now using a Rxy based mock there's quite a bit of boilerplate code needed to create the test: The `subscribe(…)` call, the `callDone` variable to track when it's finished, a Nimble `toEventually(…)` to wait for the call to finish, all the dispose bag related code and finally unexpected error reporting. By the time you've written a few tests tests you'll find yourself cutting and pasting a lot.

To be fair, RxSwift does provide a testing framework called __RxBlocking__ that can help and here's the above test converted to use it:

```swift
let mockHTTPClient = MockHTTPClientRxy()
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

It's certainly better, but there's still a fair amount of boiler plate and error checking code. Rxy takes this the next logical step, combining RxBlocking with additional error checking in it's `waitfFor…(…)` functions to remove everything except the bare essentials of your test:: 

```swift
let mockHTTPClient = MockHTTPClientRxy()
let remoteService = RemoteService(client: mockHTTPClient)

mockHTTPClient.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))

let response: RemoteCallResponse? = remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()
expect(self.mockHTTPClient.getSingleURL, line: line) == "xyz"
expect(response?.aValue, line: line) == "abc"
```

Compared to the original, it's considerable easier to read and write, and in case you didn't notice :-) It's also over half the size. Notice all the error catching code is gone, as are the RxBlocking calls.

### A complex example

Before we finish, lets look at a real world example I pulled from a large test suite. It's a good example of just how much Rxy can simplify testing RxSwift. I've changed the names to protect the innocent, but as you can see, it would take anyone some time to figure out what this test does. It certainly took me some time and I had some written comments to help.

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

Figured it out? What it's doing is sending a series of calls to an API, changing the mocked response for each one, then checking the final result. Not the greatest. Here's Rxy's version of the same test:

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

Let's take a look at the options Rxy provides for each of the available Rx types: `Observable<T>`, `Completable`, `Single<T>` and `Maybe<T>`. For each one I'll first list the functions that define the available result for the mocks, then the available wait functions you can use to wait and validate.

## Observables

### Mock value options

`.generate(using: @escaping (AnyObserver<T>) -> Void)` - Returns an observable which uses the passed closure to generate results like this:

```swift
    thingResult = .generate { observable in
        observable.on(.next(5))
        observable.on(.completed)
    }
```

`.sequence(_ values: [T])` - Returns an observable with the passed array returned as individual values followed by a completion.

`.throw(_ error: Error)` - Returns an observable with the error.

### Waits

`.waitForCompletion() -> [T]` - Waits until the observable completes. Generates a test failure on this line if the completable produces an error. Returns the values returned by the Observable.

`.waitForError() -> (error: Error, values: [T])` - Waits until the completable produces an error. Generates a test failure on this line if the completable completes instead. Returns a tuple containing both the error and any returned values.

## Completables

### Mock value options

`.completed()` - Returns a completed completable.

`.throw(_ error: Error)` - Returns a completable with the error.

### Waits

`.waitForCompletion()` - Waits until the completable completes. Generates a test failure on this line if the completable produces an error. 

`.waitForError() -> Error?` - Waits until the completable produces an error. Generates a test failure on this line if the completable completes instead.

## Singles

### Mock value options

`.value(_ value: T)` - Returns the passed value as the result of the single. 

`.value(_ value: () -> T)` - Returns the result of executing the passed closure as the result of the single. 

`.value(_ json: String)` - Decodes the passed JSON string into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.value(_ jsonFromFile: String, extension: String?, inBundleWithClass: AnyClass)` - Loads JSON from a file in a bundle and decodes it into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.throw(_ error: Error)` - Returns a single with the error.

### Waits

`.waitForSuccess() -> T?` - Waits until the single completes. Generates a test failure on this line if the single produces an error or if another error occurs such as a JSON value being incorrect. Returns the value produced by the Single.

`.waitForError() -> Error?` - Waits until the single produces an error. Generates a test failure on this line if the single completes instead.

## Maybes

### Mock value options

`.completed()` - Returns a completed maybe.

`.value(_ value: T)` - Returns the passed value as the result of the maybe. 

`.value(_ value: () -> T)` - Returns the result of executing the passed closure as the result of the maybe. 

`.value(_ json: String)` - Decodes the passed JSON string into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.value(_ jsonFromFile: String, extension: String?, inBundleWithClass: AnyClass)` - Loads JSON from a file in a bundle and decodes it into the expected return type. This assumes that the return type implements `Decodable`. A test failure will also be generated if there is an error decoding the JSON into the expected type. 

`.throw(_ error: Error)` - Returns a maybe with the error.

### Waits

`.waitForCompletion()` - Waits until the maybe completes. Generates a test failure on this line if the maybe produces an error or if it produces a value instead of completing.

`.waitForValue() -> T?` - Waits until the maybe produces a value. Generates a test failure on this line if the maybe produces an error or if it completes instead.

`.waitForError() -> Error?` - Waits until the maybe produces an error. Generates a test failure on this line if the maybe completes instead.

# Installation

## Carthage

Add this to your **Cartfile.private** file:

```swift
github "outware/Rxy"
```

