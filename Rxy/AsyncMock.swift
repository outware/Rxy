
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift
import Nimble

protocol AsyncMock {}

extension AsyncMock {
    
    /// Use whenever you need to indicate that a function is never expected to be called.
    ///
    /// Generally speaking this is mostly used by the other mocking methods here, but if there is a method within your
    /// moc that you want to expressly lock out then this can be used to perform that function.
    /// Here's an example of implementing this function.
    /// ```
    /// class MockThing: Thing {
    ///     func unexpected() {
    ///         unexpectedFunctionCall()
    ///     }
    ///     func unexpectedSingle() -> Single<Int> {
    ///         unexpectedFunctionCall()
    ///         return .error(RxyError.unexpectedMethodCall("\(#file.filename(withFunction: #function))")
    ///     }
    /// }
    /// ```
    ///
    func unexpectedFunctionCall(file: String = #file, line: UInt = #line, function: String = #function) {
        fail("Unexpected function call \(file.filename(withFunction: function))", file: file, line: line)
    }

    /// Use when you need to mock a call to a function that returns a Completable.
    ///
    /// This function will automatically execute on a background thread. The result argument can be used to specify a range of
    /// result options for the Completable. If a nil is passed, then a RxyError.unexpectedMethodCall(...) error is returned and
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
    /// - Returns: A Completable that executes on a background thread.
    func mockFunction(file: String = #file, line: UInt = #line, function: String = #function, returning result: CompletableResult?) -> Completable {
        guard let result = result else {
            unexpectedFunctionCall(file: file, line: line, function: function)
            return .error(RxyError.unexpectedMethodCall("\(file.filename(withFunction: function))"))
        }
        return result.resolve().executeInBackground()
    }

    func mockFunction<T>(file: String = #file, line: UInt = #line, function: String = #function, returning result: SingleResult<T>?) -> Single<T> {
        guard let result = result else {
            unexpectedFunctionCall(file: file, line: line, function: function)
            return .error(RxyError.unexpectedMethodCall("\(file.filename(withFunction: function))"))
        }
        return result.resolve().executeInBackground()
    }

    func mockFunction<T>(file: String = #file, line: UInt = #line, function: String = #function, returning result: MaybeResult<T>?) -> Maybe<T> {
        guard let result = result else {
            unexpectedFunctionCall(file: file, line: line, function: function)
            return .error(RxyError.unexpectedMethodCall("\(file.filename(withFunction: function))"))
        }
        return result.resolve().executeInBackground()
    }
}
