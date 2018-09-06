
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Rxy
import RxSwift
import Nimble

class Rx_ThreadingTests: XCTestCase {
    
    func testThreadExecutesInBackground() {
        let disposeBag = DisposeBag()
        Completable.create { completable in

            // Background thread validation
            expect(Thread.isMainThread).to(beFalse())

            completable(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground()
            
            // Validate
            .subscribe(
                onCompleted:{
                    expect(Thread.isMainThread).to(beTrue())
            },
                onError: { error in
                    fail("\(error)")
            }
            )
            .disposed(by: disposeBag)
    }

    func testThreadExecutesInBackgroundWithCustomSchedular() {
        let disposeBag = DisposeBag()
        Completable.create { completable in
            
            // Custom thread validation
            expect(Thread.isMainThread).to(beTrue())

            completable(.completed)
            return Disposables.create()
            }
            
            // Test
            .executeInBackground(observeOn: MainScheduler.asyncInstance)
            
            // Validate
            .subscribe(
                onCompleted:{
                    expect(Thread.isMainThread).to(beTrue())
            },
                onError: { error in
                    fail("\(error)")
            }
            )
            .disposed(by: disposeBag)
    }
}
