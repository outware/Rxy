
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Maybe. MaybeResults can return values, completed or errors.
public final class MaybeResult<T>: Result<T, Maybe<T>> {

    public static func completed() -> Self {
        return self.init { observable in
            observable.on(.completed)
        }
    }

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

    override var resolved: Maybe<T> {
        return super.resolveObservable.asMaybe()
    }
}
