
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

/**
 Base class for all results.
 
 Provides a common error result which all Observables can use.
 */
class BaseResolver {
    
    fileprivate var error: Error?
    
    init() {}
    
    init(error: Error) {
        self.error = error
    }
}

class ValueResolver<T>: BaseResolver {
    
    fileprivate var valueClosure: (() -> T)?
    
    // MARK Lifecycle
    
    convenience init(value: @escaping () -> T) {
        self.init()
        self.valueClosure = value
    }
}

protocol Resolver {
    associatedtype Sequence
    func resolve() -> Sequence
}

protocol Resolvable {
    associatedtype Sequence
    var resolve: () -> Sequence { get set }
}

final class CompletableResolver: BaseResolver, Resolver {
    
    /// Used internally to resolve the result.
    func resolve() -> Completable {
        if let error = self.error {
            return Completable.error(error)
        }
        return Completable.empty()
    }
}

final class SingleResolver<T>: ValueResolver<T>, Resolver {
    
    /// Used internally to resolve the result.
    func resolve() -> Single<T> {
        if let valueClosure = valueClosure {
            return Single<T>.just(valueClosure())
        }
        return Single<T>.error(self.error!)
    }
}

final class MaybeResolver<T>: ValueResolver<T>, Resolver {
    
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
