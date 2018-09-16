
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Completable. CompletableResults can return completed or errors.
public final class CompletableResult: Result<CompletableEvent>, Resolvable {

    public static func completed() -> Self {
        return self.init { completable in
            completable(.completed)
        }
    }

    public static func `throw`(_ error: Error) -> Self {
        return self.init { completable in
            completable(.error(error))
        }
    }

    var resolved: Completable {
        return Completable.create { completable in
            return self.resolve(completable)
        }
    }
}
