
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

/**
 Resolvers provide the implementations for produce results for mocked calls.
 */

/// Base resolver for all resolves. Can produce an error result or a void result.
class BaseResolver {
    
    fileprivate var error: Error?
    
    init() {}
    
    init(error: Error) {
        self.error = error
    }
}

/// Base resolver for resolvers that can produce values.
class ValueResolver<T>: BaseResolver {
    
    var valueClosure: (() throws -> T)?
    
    // MARK Lifecycle
    
    convenience init(value: @escaping () throws -> T) {
        self.init()
        self.valueClosure = value
    }
    
    /// Shared core logic for processing values.
    func resolveValue<O>(success: (T) -> O, failure: (Error) -> O) -> O? {
        
        // If there is a value closure then return it or fail with any error thrown by it.
        if let valueClosure = valueClosure {
            do {
                return success(try valueClosure())
            }
            catch let error {
                return failure(error)
            }
        }

        // If there is an error then return it.
        if let error = self.error {
            return failure(error)
        }

        // Otherwise return a nil.
        return nil
    }
}

/// Resolvers can resolve a result of a mocked call.
protocol Resolver {
    associatedtype Sequence
    func resolve() -> Sequence
}

/// Resolvables can be asked to resolve a result.
protocol Resolvable {
    associatedtype Sequence
    var resolve: () -> Sequence { get set }
}

// MARK: - Instances

final class CompletableResolver: BaseResolver, Resolver {
    
    func resolve() -> Completable {
        if let error = self.error {
            return Completable.error(error)
        }
        return Completable.empty()
    }
}

final class SingleResolver<T>: ValueResolver<T>, Resolver {
    
    func resolve() -> Single<T> {
        guard let result = resolveValue(success: { Single<T>.just($0) }, failure: { Single<T>.error($0) }) else {
            fatalError("Singles must return a value or an error")
        }
        return result
    }
}

final class MaybeResolver<T>: ValueResolver<T>, Resolver {
    
    func resolve() -> Maybe<T> {
        if let result = resolveValue(success: { Maybe<T>.just($0) }, failure: { Maybe<T>.error($0) }) {
            return result
        }
        return Maybe<T>.empty()
    }
}
