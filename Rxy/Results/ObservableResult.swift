
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

public class BaseResult<T, O>: Resolvable {
    
    var eventFactory: (AnyObserver<T>) -> Void
    
    required init(factory: @escaping (AnyObserver<T>) -> Void) {
        self.eventFactory = factory
    }
    
    var resolveObservable: Observable<T> {
        return Observable<T>.create { observable in
            self.eventFactory(observable)
            return Disposables.create()
        }
    }
    
    var resolved: O {
        fatalError()
    }
}


/// Result type for mocks which return an Observable. ObservableResults can return any number of values sequenced or timed and with or without errors.
public final class ObservableResult<T>: Resolvable {

    var eventFactory: (AnyObserver<T>) -> Void

    required init(factory: @escaping (AnyObserver<T>) -> Void) {
        self.eventFactory = factory
    }

    public static func generate(using: @escaping (AnyObserver<T>) -> Void) -> Self {
        return self.init { observable in
            using(observable)
        }
    }

    public static func values(_ values:[T]) -> Self {
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

    var resolved: Observable<T> {
        return Observable<T>.create { observable in
            self.eventFactory(observable)
            return Disposables.create()
        }
    }
}
