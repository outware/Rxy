
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Defines functions for returning value results.
public protocol ValueFactory: ErrorFactory {

    /// The type of the value.
    associatedtype Element

    init(value: @escaping () -> Element)

    /**
     Sets a value.

     - Parameter value: The value to be returned.
     - Returns: An instance of the result.
     */
    static func `value`(_ value: @autoclosure @escaping () -> Element) -> Self

    /**
     Sets a closure which returns a value.

     - Parameter value: The closure to execute.
     - Returns: An instance of the result.
     */
    static func `value`(_ value: @escaping () -> Element) -> Self
}

public extension ValueFactory {

    public static func `value`(_ value: @autoclosure @escaping () -> Element) -> Self {
        return self.init(value: value)
    }

    public static func `value`(_ value: @escaping () -> Element) -> Self {
        return self.init(value: value)
    }
}
