//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Single. SingleResults can return values or errors.
public final class SingleResult<T>: Result<T, Single<T>>, Resolvable {

    /**
     Returns a Single with the passed value as the result.
     
     - Parameter value: the value to return.
    */
    public static func `value`(_ value: @autoclosure @escaping () -> T) -> Self {
        return self.init { observable in
            observable.on(.next(value()))
            observable.on(.completed)
        }
    }

    /**
     Returns a Single with a value produced by the passed closure.
     
     - Parameter value: A closure that will produce the value to return.
    */
    public static func `value`(_ value: @escaping () -> T) -> Self {
        return self.init { observable in
            observable.on(.next(value()))
            observable.on(.completed)
        }
    }

    /**
     Returns a Single with an error.
     
     - Parameter error: The error to return.
    */
    public static func `throw`(_ error: Error) -> Self {
        return self.init { observable in
            observable.on(.error(error))
        }
    }

    func resolve() -> Single<T> {
        return super.resolveObservable().asSingle()
    }
}
