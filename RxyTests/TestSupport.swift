
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

extension PrimitiveSequence {
    
    /// Quick background processing for tests.
    func testInBackground() -> PrimitiveSequence<Trait, Element> {
        return self.observeOn(MainScheduler.asyncInstance).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

