//
//  RxyTests.swift
//  RxyTests
//
//  Created by Derek Clarkson on 30/8/18.
//  Copyright © 2018 Derek Clarkson. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
@testable import Rxy

class RxyTests: XCTestCase {
    
    func testJustAsyncExecution() {
        
        let single = Single<String>.just("abc")
            .observeOn(MainScheduler.asyncInstance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        
        let result = single.toBlocking().materialize()
        
        print("Z")
    }
}
