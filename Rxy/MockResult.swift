
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

/**
 Base class for all results.
 
 Provides a common error result which all Observables can use.
*/
public class BaseResult {

    fileprivate var error: Error?

    fileprivate init() {}

    required init(error: Error) {
        self.error = error
    }

    /**
     Tells the mock to return a Single with an error.

     - Parameter error: The error to return.
     - Returns: A Single.
     */
    public static func `throw`(_ error: Error) -> Self {
        return self.init(error: error)
    }
}

// MARK: - CompletableResult

/**
 Defines possible results from mocks representing functions returning a Completable.
 */
public final class CompletableResult: BaseResult, Resolvable {

    // MARK: Factory methods

    /**
     Tells the mock to return a successful result.
    */
    public static func success() -> CompletableResult {
        return CompletableResult()
    }

    // MARK: Tasks

    /// Used internally to resolve the result.
    func resolve() -> Completable {
        if let error = self.error {
            return Completable.error(error)
        }
        return Completable.empty()
    }
}

protocol Resolvable {
    associatedtype ObservableType
    func resolve() -> ObservableType
}

// MARK: - SingleResult

/// Defines the possible results that can be returned from the mock of a function that returns a Single.
public final class SingleResult<T>: BaseResult {

    fileprivate var valueClosure: (() -> T)?

    // MARK Lifecycle

    private convenience init(value: @autoclosure @escaping () -> T) {
        self.init()
        self.valueClosure = value
    }

    private convenience init(value: @escaping () -> T) {
        self.init()
        self.valueClosure = value
    }

    // MARK: Factory methods

    /**
     Tells the mock to return the passed value.
     
     - Parameter value: The value to return from the Single.
     */
    public static func `value`(_ value: T) -> SingleResult<T> {
        return SingleResult<T>(value: value)
    }

    /**
     Tells the mock to return a value which is the result of executing the passed closure.
     
     - Parameter value: A closure that produces the value to return from the Single.
     */
    public static func `value`(_ value: @escaping () -> T) -> SingleResult<T> {
        return SingleResult(value: value)
    }

    // MARK: Tasks
    
    /// Used internally to resolve the result.
    func resolve() -> Single<T> {
        if let valueClosure = valueClosure {
            return Single<T>.just(valueClosure())
        }
        return Single<T>.error(self.error!)
    }
}

// MARK: - MaybeResult

/// Defines the possible results that can be returned from the mock of a function that returns a Meybe.
public final class MaybeResult<T>: BaseResult {

    fileprivate var valueClosure: (() -> T)?

    // MARK Lifecycle

    private convenience init(value: @autoclosure @escaping () -> T) {
        self.init()
        self.valueClosure = value
    }

    private convenience init(value: @escaping () -> T) {
        self.init()
        self.valueClosure = value
    }

    // MARK: Factory methods

    /**
     Tells the mock to return the passed value.
     
     - Parameter value: The value to return from the Maybe.
     */
    public static func `value`(_ value: T) -> MaybeResult<T> {
        return MaybeResult<T>(value: value)
    }

    /**
     Tells the mock to return a value which is the result of executing the passed closure.
     
     - Parameter value: A closure that produces the value to return from the maybe.
     */
    public static func `value`(_ value: @escaping () -> T) -> MaybeResult<T> {
        return MaybeResult(value: value)
    }

    /**
     Tells the mock to successfully complete without returning a value.
     */
    public static func success() -> MaybeResult<T> {
        return MaybeResult<T>()
    }
    
    // MARK: Tasks
    
    /// Used internally to resolve the result.
    func resolve() -> Maybe<T> {
        if let valueClosure = valueClosure {
            return Maybe.just(valueClosure())
        }
        if let error = self.error {
            return Maybe.error(error)
        }
        return Maybe.empty()
    }
}
