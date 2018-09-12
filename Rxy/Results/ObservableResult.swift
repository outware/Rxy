
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

public final class ObservableResult<T>: ErrorFactory, Resolvable {

    var resolve: () -> Observable<T>

    public init(error: Error) {
        self.resolve = ObservableResolver<T>(error: error).resolve
    }

}
