
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

public protocol ErrorFactory {

    init(error: Error)

    /**
     Creates and returns a result which resolves to an error.
     
     - Parameter error: The error to return.
     - Returns: An instance of the result.
     */
    static func `throw`(_ error: Error) -> Self
}

public protocol ValueFactory: ErrorFactory {
    associatedtype Element
    init(value: @escaping () -> Element)
    static func `value`(_ value: @autoclosure @escaping () -> Element) -> Self
    static func `value`(_ value: @escaping () -> Element) -> Self
}

public protocol CompletionFactory: ErrorFactory {
    init()
    static func completed() -> Self
}

public extension ErrorFactory {

    public static func `throw`(_ error: Error) -> Self {
        return self.init(error: error)
    }
}

public extension CompletionFactory {
    
    public static func completed() -> Self {
        return self.init()
    }
}

public extension ValueFactory {
    
    public static func `value`(_ value: @autoclosure @escaping () -> Element) -> Self {
        return self.init(value: value)
    }
    
    public static func `value`(_ value: @escaping () -> Element) -> Self {
        return self.init(value: value)
    }
}

// MARK: - CompletableResult

public final class CompletableResult: ErrorFactory, CompletionFactory, Resolvable {
    
    var resolve: () -> Completable
    
    public init() {
        self.resolve = CompletableResolver().resolve
    }
    
    public init(error: Error) {
        self.resolve = CompletableResolver(error: error).resolve
    }
}

// MARK: - SingleResult

public final class SingleResult<T>: ErrorFactory, ValueFactory, Resolvable {
    
    var resolve: () -> Single<T>
    
    public init(error: Error) {
        self.resolve = SingleResolver<T>(error: error).resolve
    }
    
    public init(value: @escaping () -> T) {
        self.resolve = SingleResolver<T>(value: value).resolve
    }
}

// MARK: - MaybeResult

/// Defines the possible results that can be returned from the mock of a function that returns a Meybe.
public final class MaybeResult<T>: ErrorFactory, ValueFactory, CompletionFactory, Resolvable {

    var resolve: () -> Maybe<T>
    
    public init() {
        self.resolve = MaybeResolver<T>().resolve
    }
    
    public init(error: Error) {
        self.resolve = MaybeResolver<T>(error: error).resolve
    }
    
    public init(value: @escaping () -> T) {
        self.resolve = MaybeResolver<T>(value: value).resolve
    }
    
}

//
//// MARK: - JSON
//
//protocol JSONLoadable {
//    static func `jsonValue`(_ json: String) -> Self
//}
//
//extension JSONLoadable where Self: ValueResult, Self.Element: Decodable {
//
//    static func `jsonValue`(_ json: String) -> Self {
//        let decoder = JSONDecoder.init()
//        if let jsonData = json.data(using: .utf8) {
//            do {
//                let obj = try decoder.decode(Element.self, from: jsonData)
//                return value { obj }
//            }
//            catch let error {
//                return self.throw(error)
//            }
//        }
//
//        return self.throw(RxyError.invalidJSON)
//    }
//}

