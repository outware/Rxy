
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Completable. CompletableResults can return completed or errors.
public final class CompletableResult: CompletionFactory, Resolvable {

    var resolve: () -> Completable

    public init() {
        self.resolve = CompletableResolver().resolve
    }

    public init(error: Error) {
        self.resolve = CompletableResolver(error: error).resolve
    }
}
