
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Completable. CompletableResults can return completed or errors.
public final class CompletableResult: Result<Any, Completable>, Resolvable {
    
    /**
    Returns a completed Completable.
     */
    public static func completed() -> Self {
        return self.init { observable in
            observable.on(.completed)
        }
    }
    
    /**
     Returns a completable with an error.
     
     - Parameter error: The error to return.
    */
    public static func `throw`(_ error: Error) -> Self {
        return self.init { observable in
            observable.on(.error(error))
        }
    }
    
    func resolve() -> Completable {
        return super.resolveObservable().ignoreElements()
    }
}
