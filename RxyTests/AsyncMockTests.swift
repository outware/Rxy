
//  Created by Derek Clarkson on 30/8/18.

import XCTest
import RxSwift
import Nimble
@testable import Rxy

private protocol DoSomething {
    func doSingleThing() -> Single<Int>
}

private class MockSomething: AsyncMock {
    
    func doUnexpectedMethod() {
        unexpectedFunctionCall()
    }
    
    var doSingleThingResult: SingleResult<Int>?
    func doSingleThing() -> Single<Int> {
        return mockFunction(returning: doSingleThingResult)
    }
}

class AsyncMockTests: XCTestCase {
    
    private var mock: MockSomething!
    
    override func setUp() {
        mock = MockSomething()
    }
    
    func testUnexpectedMethodCalled() {
        expectNimble(error: "Unexpected function call AsyncMockTests.doUnexpectedMethod()") {
            mock.doUnexpectedMethod()
        }
    }
    
    func testMockFunctionReturnsResult() {
        mock.doSingleThingResult = .value(5)
        let result = mock.doSingleThing().waitForSuccess()
        expect(result) == 5
    }
    
    func testMockFunctionTriggersUnexpectedMethodCall() {
        expectNimble(error: "Expected a single value, got error RxyError.unexpectedMethodCall(\"AsyncMockTests.doSingleThing()\") instead") {
            mock.doSingleThing().waitForSuccess()
        }
    }
    
}
