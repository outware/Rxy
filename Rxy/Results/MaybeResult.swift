
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Maybe. MaybeResults can return values, completed or errors.
public final class MaybeResult<T>: Result<T>, Resolvable {

    /// Returns a completed Maybe.
    public static func completed() -> Self {
        return self.init { observable in
            observable.on(.completed)
        }
    }

    /**
     Returns a Maybe with a value.
     
     - Parameter value: The value to return.
    */
    public static func `value`(_ value: @autoclosure @escaping () -> T) -> Self {
        return self.init { observable in
            observable.on(.next(value()))
            observable.on(.completed)
        }
    }

    /**
     Returns a Maybe with a value produced by a closure.
     
     - Parameter value: A closure that produces the desired value.
    */
    public static func `value`(_ value: @escaping () -> T) -> Self {
        return self.init { observable in
            observable.on(.next(value()))
            observable.on(.completed)
        }
    }

    /**
     Returns a Maybe with an error.
     
     - Parameter error: The error to be returned.
    */
    public static func `throw`(_ error: Error) -> Self {
        return self.init { observable in
            observable.on(.error(error))
        }
    }

    func resolve() -> Maybe<T> {
        return super.resolveObservable().asMaybe()
    }
}
