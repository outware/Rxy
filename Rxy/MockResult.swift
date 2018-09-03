
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

// MARK: - SingleResult

public final class SingleResult<T> {
    
    private var error: Error?
    private var valueClosure: (() -> T)?

    // MARK Lifecycle
    
    private init(error: Error) {
        self.error = error
    }

    private init(value: @autoclosure @escaping () -> T) {
        self.valueClosure = value
    }

    private init(value: @escaping () -> T) {
        self.valueClosure = value
    }

    // MARK: Factory methods
    
    public static func `throw`(_ error: Error) -> SingleResult<T> {
        return SingleResult<T>(error: error)
    }

    public static func `value`(_ value: T) -> SingleResult<T> {
        return SingleResult<T>(value: value)
    }

    public static func `value`(_ value: @escaping () -> T) -> SingleResult<T> {
        return SingleResult(value: value)
    }

    // MARK: Tasks
    
    func resolve() -> Single<T> {
        if let valueClosure = valueClosure {
            return Single.just(valueClosure())
        }
        return Single.error(self.error!)
    }
}

// MARK: - CompletableResult

public final class CompletableResult {
    
    private var error: Error?
    
    // MARK Lifecycle
    
    private init(error: Error) {
        self.error = error
    }
    
    private init() {}
    
    // MARK: Factory methods
    
    public static func `throw`(_ error: Error) -> CompletableResult {
        return self.init(error: error)
    }
    
    public static func success() -> CompletableResult {
        return CompletableResult()
    }
    
    // MARK: Tasks
    
    func resolve() -> Completable {
        if let error = self.error {
            return Completable.error(error)
        }
        return Completable.empty()
    }
}

// MARK: - MaybeResult

public final class MaybeResult<T> {
    
    private var error: Error?
    private var valueClosure: (() -> T)?
    
    // MARK Lifecycle

    private init() {}

    private init(error: Error) {
        self.error = error
    }
    
    private init(value: @autoclosure @escaping () -> T) {
        self.valueClosure = value
    }
    
    private init(value: @escaping () -> T) {
        self.valueClosure = value
    }
    
    // MARK: Factory methods
    
    public static func success() -> MaybeResult<T> {
        return MaybeResult<T>()
    }
    
    public static func `throw`(_ error: Error) -> MaybeResult<T> {
        return MaybeResult<T>(error: error)
    }
    
    public static func `value`(_ value: T) -> MaybeResult<T> {
        return MaybeResult<T>(value: value)
    }
    
    public static func `value`(_ value: @escaping () -> T) -> MaybeResult<T> {
        return MaybeResult(value: value)
    }
    
    // MARK: Tasks
    
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

