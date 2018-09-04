//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

extension PrimitiveSequence {
    
    /// Quick background processing for tests.
    func executeInBackground(observeOn schedular: SchedulerType = MainScheduler.asyncInstance) -> PrimitiveSequence<Trait, Element> {
        return self.observeOn(schedular).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

