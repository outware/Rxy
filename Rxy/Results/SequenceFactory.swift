
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

public protocol SequenceFactory {

    /// The type of values returned by the observable
    associatedtype Element

    /**
     Sets a series of values to be returned.

     - Parameter values: An array of values to be returned.
     - Returns: An instance of the result.
     */
    static func values(_ values: [Element]) -> Self
}

