
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return an Observable. ObservableResults can return any number of values sequenced or timed and with or without errors.
public final class ObservableResult<T>: Result<T, Observable<T>> {

    public static func generate(using: @escaping (AnyObserver<T>) -> Void) -> Self {
        return self.init { observable in
            using(observable)
        }
    }

    public static func sequence(_ values:[T]) -> Self {
        return self.init { observable in
            values.forEach { observable.on(.next($0)) }
            observable.on(.completed)
        }
    }
    
    public static func `throw`(_ error: Error) -> Self {
        return self.init { observable in
            observable.on(.error(error))
        }
    }

    override var resolved: Observable<T> {
        return super.resolveObservable
    }
}
