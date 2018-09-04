
//  Created by Derek Clarkson on 30/8/18.

import XCTest
import RxSwift
import Nimble
@testable import Rxy

private protocol DoSomething {
    func doSingleThing() -> Single<Int>
}

private class MockSomething: BaseMock {
    
    var doSingleThingResult: SingleResult<Int>?
    func doSingleThing() -> Single<Int> {
        return mockFunction(returning: doSingleThingResult)
    }
}

class BaseMockTests: XCTestCase {
    
    func testUnexpectedSingle() {
        let mock = MockSomething()
        mock.doSingleThing().waitForSuccess()
    }
    
}
