
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Maybe. MaybeResults can return values, completed or errors.
public final class MaybeResult<T>: Result<MaybeEvent<T>>, Resolvable {

    public static func completed() -> Self {
        return self.init { maybe in
            maybe(.completed)
        }
    }

    public static func `value`(_ value: @autoclosure @escaping () -> T) -> Self {
        return self.init { maybe in
            maybe(.success(value()))
        }
    }

    public static func `value`(_ value: @escaping () -> T) -> Self {
        return self.init { single in
            single(.success(value()))
        }
    }

    public static func `throw`(_ error: Error) -> Self {
        return self.init { maybe in
            maybe(.error(error))
        }
    }

    var resolved: Maybe<T> {
        return Maybe<T>.create { maybe in
            return self.resolve(maybe)
        }
    }
}

public extension MaybeResult where T:Decodable {

    public static func json(_ json: String) -> Self {
        return loadJSON(
            successClosure: { $0(.success($1)) },
            errorClosure: { $0(.error($1)) },
            getDataClosure: { json.data(using: .utf8) },
            noDataError: RxyError.invalidData,
            sourceJSON: json
        )
    }

    public static func json(fromFile: String, extension ext: String? = "json", inBundleWithClass aClass: AnyClass) -> Self {
        return loadJSON(
            successClosure: { $0(.success($1)) },
            errorClosure: { $0(.error($1)) },
            getDataClosure: { Bundle.contentsOfFile(fromFile, extension: ext, fromBundleWithClass: aClass) },
            noDataError: RxyError.fileNotFound
        )
    }
}

