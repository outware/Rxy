
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Rxy
import RxSwift
import Nimble
import RxBlocking

class Rx_ThreadingTests: XCTestCase {
    
    func testThreadExecutesInBackground() {
        _ = Completable.create { completable in

            // Background thread validation
            expect(Thread.isMainThread).to(beFalse())

            completable(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground().toBlocking()
    }

    func testThreadExecutesInBackgroundWithCustomSchedular() {
        _ = Completable.create { completable in
            
            // Custom thread validation
            expect(Thread.isMainThread).to(beTrue())

            completable(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground(observeOn: MainScheduler.asyncInstance).toBlocking()
    }
}
