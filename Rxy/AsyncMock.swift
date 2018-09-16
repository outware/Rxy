
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift
import Nimble

/// Apply this protocol to gain access to a range of mocking functions for RxSwift return values.
public protocol AsyncMock {

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
    /// - Parameter file: The file that made the call. Defaults to the current file using #file
    /// - Parameter line: The line in the file that made the call. Defaults to the current line using #line
    /// - Parameter function: The function in the file that made the call. Defaults to the current function using #function
    ///
    func unexpectedFunctionCall(file: String, line: UInt, function: String)

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
    /// - Parameter file: The file that made the call. Defaults to the current file using #file
    /// - Parameter line: The line in the file that made the call. Defaults to the current line using #line
    /// - Parameter function: The function in the file that made the call. Defaults to the current function using #function
    /// - Returns: A Completable that executes on a background thread.
    func mockFunction(file: String, line: UInt, function: String, returning result: CompletableResult?) -> Completable
    
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
    /// - Parameter file: The file that made the call. Defaults to the current file using #file
    /// - Parameter line: The line in the file that made the call. Defaults to the current line using #line
    /// - Parameter function: The function in the file that made the call. Defaults to the current function using #function
    /// - Returns: A Single that executes on a background thread.
    func mockFunction<T>(file: String, line: UInt, function: String, returning result: SingleResult<T>?) -> Single<T>

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
    /// - Parameter file: The file that made the call. Defaults to the current file using #file
    /// - Parameter line: The line in the file that made the call. Defaults to the current line using #line
    /// - Parameter function: The function in the file that made the call. Defaults to the current function using #function
    /// - Returns: A Maybe that executes on a background thread.
    func mockFunction<T>(file: String, line: UInt, function: String, returning result: MaybeResult<T>?) -> Maybe<T>
    
    // MARK: Dynamic variations
    
    /// Use when you need to mock a call to a function that returns a Single with an unkknown value type.
    ///
    /// This variation is used when you want to mock a call that returns an unknown type. To handle this, define the result as an 'Any' type
    /// so that result values can be of any type.
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
    /// - Parameter file: The file that made the call. Defaults to the current file using #file
    /// - Parameter line: The line in the file that made the call. Defaults to the current line using #line
    /// - Parameter function: The function in the file that made the call. Defaults to the current function using #function
    /// - Returns: A Single that executes on a background thread.
    func mockFunction<T>(file: String, line: UInt, function: String, returning result: SingleResult<Any>?) -> Single<T>
    
    // Use when you need to mock a call to a function that returns a Maybe with an unkknown value type.
    ///
    /// This variation is used when you want to mock a call that returns an unknown type. To handle this, define the result as an 'Any' type
    /// so that result values can be of any type.
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
    /// - Parameter file: The file that made the call. Defaults to the current file using #file
    /// - Parameter line: The line in the file that made the call. Defaults to the current line using #line
    /// - Parameter function: The function in the file that made the call. Defaults to the current function using #function
    /// - Returns: A Maybe that executes on a background thread.
    func mockFunction<T>(file: String, line: UInt, function: String, returning result: MaybeResult<Any>?) -> Maybe<T>

}

// MARK: - Implementation

public extension AsyncMock {
    
    public func unexpectedFunctionCall(file: String = #file, line: UInt = #line, function: String = #function) {
        fail("Unexpected function call \(function)", file: file, line: line)
    }

    public func mockFunction(file: String = #file, line: UInt = #line, function: String = #function, returning result: CompletableResult?) -> Completable {
        return result?.resolved.executeInBackground() ?? .error(reportUnexpectedCall(file: file, line: line, function: function))
    }

    public func mockFunction<T>(file: String = #file, line: UInt = #line, function: String = #function, returning result: SingleResult<T>?) -> Single<T> {
        return result?.resolved.executeInBackground() ?? .error(reportUnexpectedCall(file: file, line: line, function: function))
    }

    public func mockFunction<T>(file: String = #file, line: UInt = #line, function: String = #function, returning result: MaybeResult<T>?) -> Maybe<T> {
        return result?.resolved.executeInBackground() ?? .error(reportUnexpectedCall(file: file, line: line, function: function))
    }

    public func mockFunction<T>(file: String = #file, line: UInt = #line, function: String = #function, returning result: SingleResult<Any>?) -> Single<T> {
        return result?.resolved.map { value -> T in
            return try self.cast(file: file, line: line, value: value)
            }
            .executeInBackground() ?? .error(reportUnexpectedCall(file: file, line: line, function: function))
    }

    public func mockFunction<T>(file: String = #file, line: UInt = #line, function: String = #function, returning result: MaybeResult<Any>?) -> Maybe<T> {
        return result?.resolved.map { value -> T in
            return try self.cast(file: file, line: line, value: value)
            }
            .executeInBackground() ?? .error(reportUnexpectedCall(file: file, line: line, function: function))
    }
    
    // MARK: Internal functions
    
    /// Handles the casting of an unknown type to the desires result type.
    private func cast<T>(file: String, line: UInt, value: Any) throws -> T {
        if let castValue = value as? T {
            return castValue
        }
        fail("Expected to return a \(T.self), but got a \(type(of: value)) instead.", file: file, line: line)
        throw RxyError.wrongType(expected: T.self, found: type(of: value))
    }

    // Reports on the error
    private func reportUnexpectedCall(file: String, line: UInt, function: String) -> Error {
        unexpectedFunctionCall(file: file, line: line, function: function)
        return RxyError.unexpectedFunctionCall(function)
    }
}
