
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

final class SingleResolver<T>: ValueResolver<T>, Resolver {

    func resolve() -> Single<T> {
        guard let result = resolveValue(success: { Single<T>.just($0) }, failure: { Single<T>.error($0) }) else {
            fatalError("Singles must return a value or an error")
        }
        return result
    }
}

