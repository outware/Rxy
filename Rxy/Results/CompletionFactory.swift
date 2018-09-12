
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Defines the 'completed()' function for results.
public protocol CompletionFactory: ErrorFactory {

    init()

    /// Tells the mock to complete without a value.
    static func completed() -> Self
}

public extension CompletionFactory {

    public static func completed() -> Self {
        return self.init()
    }
}
