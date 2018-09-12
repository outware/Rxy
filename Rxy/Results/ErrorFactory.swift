
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/**
 Result objects are used to provide result values to mock calls.
 */

/// Defines the 'throw(...)' function for results.
public protocol ErrorFactory {

    init(error: Error)

    /**
     Creates and returns a result which resolves to an error.

     - Parameter error: The error to return.
     - Returns: An instance of the result.
     */
    static func `throw`(_ error: Error) -> Self
}

public extension ErrorFactory {

    public static func `throw`(_ error: Error) -> Self {
        return self.init(error: error)
    }
}
