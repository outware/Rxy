
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Base class for mocks that provides the file and line where the mock was created. This results in
/// mocks reporting errors which would normally be buried wherever the mock is called, instead being reported
/// on the line in the test where the mock is created. This is very useful for debugging.
///
/// Here's an example of using this base mock:
/// ```
/// class MockThing: BaseMock, Thing {
///     var getCompletableResult: CompletableResult?
///     func getCompletable() -> Completable {
///         return mockFunction(returning: getCompletableResult)
///     }
/// }
/// ```
///
/// Visually it's little different to using the AsyncMock class directly. However when it's run, mock errors will be reported
/// On the line where the mock is declared, rather than the line where the mockFunction(...) call was made.

open class BaseMock: AsyncMock {
    
    private let file: String
    private let line: UInt
    
    public init(file: String = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }
    
    public func unexpectedFunctionCall(function: String = #function) {
        unexpectedFunctionCall(file: file, line: line, function: function)
    }
    
    public func mockFunction(function: String = #function, returning result: CompletableResult?) -> Completable {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
    
    public func mockFunction<T>(function: String = #function, returning result: SingleResult<T>?) -> Single<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
    
    public func mockFunction<T>(function: String = #function, returning result: MaybeResult<T>?) -> Maybe<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
    
    public func mockFunction<T>(function: String = #function, returning result: SingleResult<Any>?) -> Single<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
    
    public func mockFunction<T>(function: String = #function, returning result: MaybeResult<Any>?) -> Maybe<T> {
        return mockFunction(file: file, line: line, function: function, returning: result)
    }
}
