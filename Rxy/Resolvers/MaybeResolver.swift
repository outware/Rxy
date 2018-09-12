
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

final class MaybeResolver<T>: ValueResolver<T>, Resolver {

    func resolve() -> Maybe<T> {
        if let result = resolveValue(success: { Maybe<T>.just($0) }, failure: { Maybe<T>.error($0) }) {
            return result
        }
        return Maybe<T>.empty()
    }
}
