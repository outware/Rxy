//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Single. SingleResults can return values or errors.
public final class SingleResult<T>: ErrorFactory, ValueFactory, Resolvable {

    var resolve: () -> Single<T>

    init(resolver: SingleResolver<T>) {
        self.resolve = resolver.resolve
    }

    public init(error: Error) {
        self.resolve = SingleResolver<T>(error: error).resolve
    }

    public init(value: @escaping () -> T) {
        self.resolve = SingleResolver<T>(value: value).resolve
    }
}

extension SingleResult: JSONFactory where T: Decodable {

    public convenience init(json: String) {
        self.init(resolver: SingleResolver<T>(json: json))
    }

    public convenience init(jsonFromFile fromFile: String, extension ext: String?, inBundleWithClass aClass: AnyClass) {
        self.init(resolver: SingleResolver<T>(jsonFileName: fromFile, extension: ext, inBundleWithClass: aClass))
    }
}

