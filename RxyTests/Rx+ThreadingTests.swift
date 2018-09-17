
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Rxy
import RxSwift
import Nimble
import RxBlocking

class Rx_ThreadingTests: XCTestCase {
    
    func testPrimitiveSequenceThreadExecutesInBackground() {
        _ = Completable.create { completable in

            // Background thread validation
            expect(Thread.isMainThread).to(beFalse())

            completable(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground().toBlocking()
    }

    func testPrimitiveSequenceThreadExecutesInBackgroundWithCustomSchedular() {
        _ = Completable.create { completable in
            
            // Custom thread validation
            expect(Thread.isMainThread).to(beTrue())

            completable(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground(observeOn: MainScheduler.asyncInstance).toBlocking()
    }
    
    func testObservableThreadExecutesInBackground() {
        _ = Observable<Int>.create { observable in
            
            // Background thread validation
            expect(Thread.isMainThread).to(beFalse())
            
            observable.on(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground().toBlocking()
    }
    
    func testObservableThreadExecutesInBackgroundWithCustomSchedular() {
        _ = Observable<Int>.create { observable in
            
            // Custom thread validation
            expect(Thread.isMainThread).to(beTrue())
            
            observable.on(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground(observeOn: MainScheduler.asyncInstance).toBlocking()
    }
}
