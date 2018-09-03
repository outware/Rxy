
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

public final class SingleResult<T> {
    
    private var error: Error?
    private var valueClosure: (() -> T)?

    // MARK - Lifecycle
    
    private init(error: Error) {
        self.error = error
    }

    private init(value: @autoclosure @escaping () -> T) {
        self.valueClosure = value
    }

    private init(value: @escaping () -> T) {
        self.valueClosure = value
    }

    // MARK: - Factory methods
    
    public static func `throw`(_ error: Error) -> Self {
        return self.init(error: error)
    }

    public static func `value`(_ value: T) -> SingleResult<T> {
        return SingleResult(value: value)
    }

    public static func `value`(_ value: @escaping () -> T) -> SingleResult<T> {
        return SingleResult(value: value)
    }

    // MARK: - Tasks
    
    func resolve() -> Single<T> {
        if let valueClosure = valueClosure {
            return Single.just(valueClosure())
        }
        return Single.error(RxyError.wrongType)
    }
}

//public final class CompletableResult: MockResult {
//
//}
//
//public final class ObservableResult: MockResult {
//
//}
