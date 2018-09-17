//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

public extension PrimitiveSequence {
    
    /**
     Tells the Observable to execute on a background thread and then return on the main thread.
     
     - Parameter observeOn: Defaults to MainSchedular.asyncInstance. The schedule to execute on.
     - Returns: self.
     */
    public func executeInBackground(observeOn schedular: SchedulerType = MainScheduler.asyncInstance) -> PrimitiveSequence<Trait, Element> {
        return self.observeOn(schedular).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

public extension Observable {
    
    /**
     Tells the Observable to execute on a background thread and then return on the main thread.
     
     - Parameter observeOn: Defaults to MainSchedular.asyncInstance. The schedule to execute on.
     - Returns: self.
     */
    public func executeInBackground(observeOn schedular: SchedulerType = MainScheduler.asyncInstance) -> Observable<Element> {
        return self.observeOn(schedular).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

