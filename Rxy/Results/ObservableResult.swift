
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return an Observable. ObservableResults can return any number of values sequenced or timed and with or without errors.
public final class ObservableResult<T>: Result<T>, Resolvable {

    /**
    Returns an Observable which produces values from the passed closure. The observable event is passed to the closure so values can be returned.
     
     - Parameter using: A closure which is passed an AnyObserver<T> argument. This argument must then be used to generated the results of the
     observable.
    */
    public static func generate(using: @escaping (AnyObserver<T>) -> Void) -> Self {
        return self.init { observable in
            using(observable)
        }
    }

    /**
     Returns an Observable which generates a list of values from the passed array.
     
     - Parameter sequence: An array of value to return.
    */
    public static func sequence(_ values:[T]) -> Self {
        return self.init { observable in
            values.forEach { observable.on(.next($0)) }
            observable.on(.completed)
        }
    }

    /**
     Returns an Observable with an error.
     
     - Parameter error: The error to return.
    */
    public static func `throw`(_ error: Error) -> Self {
        return self.init { observable in
            observable.on(.error(error))
        }
    }

    func resolve() -> Observable<T> {
        return super.resolveObservable()
    }
}
