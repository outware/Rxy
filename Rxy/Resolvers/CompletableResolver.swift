
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

final class CompletableResolver: BaseResolver, Resolver {

    func resolve() -> Completable {
        if let error = self.error {
            return Completable.error(error)
        }
        return Completable.empty()
    }
}
