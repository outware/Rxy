//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Single. SingleResults can return values or errors.
public final class SingleResult<T>: Result<T, Single<T>> {

    public static func `value`(_ value: @autoclosure @escaping () -> T) -> Self {
        return self.init { observable in
            observable.on(.next(value()))
            observable.on(.completed)
        }
    }

    public static func `value`(_ value: @escaping () -> T) -> Self {
        return self.init { observable in
            observable.on(.next(value()))
            observable.on(.completed)
        }
    }

    public static func `throw`(_ error: Error) -> Self {
        return self.init { observable in
            observable.on(.error(error))
        }
    }

    override var resolved: Single<T> {
        return super.resolveObservable.asSingle()
    }
}
