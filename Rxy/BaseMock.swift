
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Base class for mocks that tracks the file and line where the mock was created.
///
/// This results in mocks reporting errors which would normally be buried wherever the mock is called, instead being reported
/// on the line in the test where the mock is created. This is very useful for debugging.
///
/// Using BaseMock is no different to using the AsyncMock class directly. However when it's run, mock errors will be reported
/// On the line where the mock is declared, rather than the line where the mockFunction(...) call was made.
open class BaseMock: AsyncMock {
    
    private let file: String
    private let line: UInt

    /**
     Default initializer. Usually you don't pass any arguments to this initializer.

     - Parameter file: Defaults to the current file.
     - Parameter line: Defaults to the current line.
    */
    public init(file: String = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Use whenever you need to indicate that a function is never expected to be called.
    ///
    /// Generally speaking this is mostly used by the other mocking functions here, but if there is a function within your
    /// mock that you want to expressly lock out then this can be used to perform that function.
    /// Here's an example of implementing this function.
    /// ```
    /// class MockThing: Thing {
    ///     func unexpected() {
    ///         unexpectedFunctionCall()
    ///     }
    ///     func unexpectedSingle() -> Single<Int> {
    ///         unexpectedFunctionCall()
    ///         return .error(RxyError.unexpectedFunctionCall("\(#file.filename(withFunction: #function))")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    ///
    public func unexpectedFunctionCall(function: String = #function) {
        unexpectedFunctionCall(file: file, line: line, function: function)
    }
    
    /// Use when you need to mock a call to a function that returns a Completable.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Completable. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getCompletableResult: CompletableResult?
    ///     func getCompletable() -> Completable {
    ///         return mockFunction(returning: getCompletableResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of CompletableResult that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: A Completable that executes on a background thread.
    public func mockFunction(function: String = #function, returning result: CompletableResult?) -> Completable {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }

    /// Use when you need to mock a call to a function that returns a Single.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Single. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getSingleResult: SingleResult<Int>?
    ///     func getSingle() -> Single<Int> {
    ///         return mockFunction(returning: getSingleResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of SingleResult that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: A Single that executes on a background thread.
    public func mockFunction<T>(function: String = #function, returning result: SingleResult<T>?) -> Single<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
    
    /// Use when you need to mock a call to a function that returns a Maybe.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Maybe. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getMaybeResult: MaybeResult<Int>?
    ///     func getMaybe() -> Maybe<Int> {
    ///         return mockFunction(returning: getMaybeResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of MaybeResult that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: A Maybe that executes on a background thread.
    public func mockFunction<T>(function: String = #function, returning result: MaybeResult<T>?) -> Maybe<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }

    /// Use when you need to mock a call to a function that returns an Observable.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Maybe. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getObservableResult: ObservableResult<Int>?
    ///     func getObservable() -> Observable<Int> {
    ///         return mockFunction(returning: getObservableResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of ObservableResult that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: An Observable that executes on a background thread.
    public func mockFunction<T>(function: String = #function, returning result: ObservableResult<T>?) -> Observable<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }

    // MARK: - Dynamic variations

    /// Use when you need to mock a call to a function that accesses a mock, requesting different result types from that mock for each call.
    ///
    /// By using the Any type, it's possible to match the value to be returned to the expected type for the call.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Single. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getSingleResult: SingleResult<Any>?
    ///     func getSingle() -> Single<Int> {
    ///         return mockFunction(returning: getSingleResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of SingleResult<Any> that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: A Single that executes on a background thread.
    public func mockFunction<T>(function: String = #function, returning result: SingleResult<Any>?) -> Single<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }

    /// Use when you need to mock a call to a function that accesses a mock, requesting different result types from that mock for each call.
    ///
    /// By using the Any type, it's possible to match the value to be returned to the expected type for the call.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Maybe. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getMaybeResult: MaybeResult<Any>?
    ///     func getMaybe() -> Maybe<Int> {
    ///         return mockFunction(returning: getMaybeResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of MaybeResult<Any> that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: A Maybe that executes on a background thread.
    public func mockFunction<T>(function: String = #function, returning result: MaybeResult<Any>?) -> Maybe<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }

    /// Use when you need to mock a call to a function that accesses a mock, requesting different result types from that mock for each call.
    ///
    /// By using the Any type, it's possible to match the value to be returned to the expected type for the call.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Maybe. If a nil is passed, then a RxyError.unexpectedFunctionCall(...) error is returned and
    /// a Nimble fail is generated. Here's an example of using this function:
    /// ```
    /// class MockThing: Thing {
    ///     var getObservableResult: ObservableResult<Any>?
    ///     func getObservable() -> Observable<Int> {
    ///         return mockFunction(returning: getObservableResult)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter returning: An instance of ObservableResult<Any> that is queried for the mock result of the call.
    /// - Parameter function: The function in the file that made the call. Defaults to the current function.
    /// - Returns: An Observable that executes on a background thread.
    public func mockFunction<T>(function: String = #function, returning result: ObservableResult<Any>?) -> Observable<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
}
