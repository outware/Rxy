
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxBlocking
import RxSwift
import Nimble

/// This extension provides wrappers for asynchronous observables which convert them to synchronous and generate Nimble errors
/// if the result is not the expected one.

public extension PrimitiveSequence {
    
    var result: MaterializedSequenceResult<Element> {
        return self.toBlocking().materialize()
    }
}
