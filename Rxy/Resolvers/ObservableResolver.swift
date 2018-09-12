
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

final class ObservableResolver<T>: BaseResolver, Resolver {

    func resolve() -> Observable<T> {
        return Observable.create { observer in
            return Disposables.create()
        }
    }
}
