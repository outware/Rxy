
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

/**
 Result objects are used to provide result values to mock calls.
 */

/// Defines the 'throw(...)' function for results.
public protocol ErrorFactory {
    
    init(error: Error)

    /**
     Creates and returns a result which resolves to an error.
     
     - Parameter error: The error to return.
     - Returns: An instance of the result.
     */
    static func `throw`(_ error: Error) -> Self
}

public extension ErrorFactory {
    
    public static func `throw`(_ error: Error) -> Self {
        return self.init(error: error)
    }
}

/// Defines functions for returning value results.
public protocol ValueFactory: ErrorFactory {

    /// The type of the value.
    associatedtype Element
    
    init(value: @escaping () -> Element)

    /**
     Sets a value.
     
     - Parameter value: The value to be returned.
     - Returns: An instance of the result.
    */
    static func `value`(_ value: @autoclosure @escaping () -> Element) -> Self

    /**
     Sets a closure which returns a value.
     
     - Parameter value: The closure to execute.
     - Returns: An instance of the result.
     */
    static func `value`(_ value: @escaping () -> Element) -> Self
}

public extension ValueFactory {
    
    public static func `value`(_ value: @autoclosure @escaping () -> Element) -> Self {
        return self.init(value: value)
    }
    
    public static func `value`(_ value: @escaping () -> Element) -> Self {
        return self.init(value: value)
    }
}

/// Defines the 'completed()' function for results.
public protocol CompletionFactory: ErrorFactory {

    init()

    /// Tells the mock to complete without a value.
    static func completed() -> Self
}

public extension CompletionFactory {
    
    public static func completed() -> Self {
        return self.init()
    }
}

// MARK: - Implementations

/// Result type for mocks which return a Completable. CompletableResults can return completed or errors.
public final class CompletableResult: ErrorFactory, CompletionFactory, Resolvable {
    
    var resolve: () -> Completable
    
    public init() {
        self.resolve = CompletableResolver().resolve
    }
    
    public init(error: Error) {
        self.resolve = CompletableResolver(error: error).resolve
    }
}

/// Result type for mocks which return a Single. SingleResults can return values or errors.
public final class SingleResult<T>: ErrorFactory, ValueFactory, Resolvable {
    
    var resolve: () -> Single<T>
    
    init(resolver: SingleResolver<T>) {
        self.resolve = resolver.resolve
    }
    
    public init(error: Error) {
        self.resolve = SingleResolver<T>(error: error).resolve
    }
    
    public init(value: @escaping () -> T) {
        self.resolve = SingleResolver<T>(value: value).resolve
    }
}

/// Result type for mocks which return a Maybe. MaybeResults can return values, completed or errors.
public final class MaybeResult<T>: ErrorFactory, ValueFactory, CompletionFactory, Resolvable {
    
    var resolve: () -> Maybe<T>
    
    public init() {
        self.resolve = MaybeResolver<T>().resolve
    }
    
    init(resolver: MaybeResolver<T>) {
        self.resolve = resolver.resolve
    }
    
    public init(error: Error) {
        self.resolve = MaybeResolver<T>(error: error).resolve
    }
    
    public init(value: @escaping () -> T) {
        self.resolve = MaybeResolver<T>(value: value).resolve
    }
}
