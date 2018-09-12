
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Result type for mocks which return a Maybe. MaybeResults can return values, completed or errors.
public final class MaybeResult<T>: ErrorFactory, ValueFactory, CompletionFactory, Resolvable {

    var resolve: () -> Maybe<T>

    public init() {
        self.resolve = MaybeResolver<T>().resolve
    }

    init(resolver: MaybeResolver<T>) {
        self.resolve = resolver.resolve
    }

    public init(error: Error) {
        self.resolve = MaybeResolver<T>(error: error).resolve
    }

    public init(value: @escaping () -> T) {
        self.resolve = MaybeResolver<T>(value: value).resolve
    }
}

extension MaybeResult: JSONFactory where T: Decodable {

    public convenience init(json: String) {
        self.init(resolver: MaybeResolver<T>(json: json))
    }

    public convenience init(jsonFromFile fromFile: String, extension ext: String?, inBundleWithClass aClass: AnyClass) {
        self.init(resolver: MaybeResolver<T>(jsonFileName: fromFile, extension: ext, inBundleWithClass: aClass))
    }
}
