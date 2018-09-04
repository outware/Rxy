
//  Created by Derek Clarkson on 30/8/18.

import XCTest
import RxSwift
import Nimble
@testable import Rxy

private class MockSomething: AsyncMock {
    
    func doUnexpectedMethod() {
        unexpectedFunctionCall()
    }
    
    var doSingleThingResult: SingleResult<Int>?
    func doSingleThing() -> Single<Int> {
        return mockFunction(returning: doSingleThingResult)
    }
    
    var doCompletableThingResult: CompletableResult?
    func doCompletableThing() -> Completable {
        return mockFunction(returning: doCompletableThingResult)
    }
    
    var doMaybeThingResult: MaybeResult<Int>?
    func doMaybeThing() -> Maybe<Int> {
        return mockFunction(returning: doMaybeThingResult)
    }
    
    //    var doDynamicThingResult: SingleResult<Any>?
    //    func doDynamicThing<T>() -> Single<T> {
    //        return mockFunction(returning: doDynamicThingResult)
    //    }
    
}

class AsyncMockTests: XCTestCase {
    
    private var mock: MockSomething!
    
    override func setUp() {
        mock = MockSomething()
    }
    
    // MARK: - Core tests
    
    func testUnexpectedMethodCalled() {
        expectNimble(error: "Unexpected function call AsyncMockTests.doUnexpectedMethod()") {
            mock.doUnexpectedMethod()
        }
    }
    
    func testMockFunctionSingleReturnsResult() {
        mock.doSingleThingResult = .value(5)
        let result = mock.doSingleThing().waitForSuccess()
        expect(result) == 5
    }
    
    func testMockFunctionSingleTriggersUnexpectedMethodCall() {
        expectNimble(error: "Expected a single value, got error RxyError.unexpectedMethodCall(\"AsyncMockTests.doSingleThing()\") instead") {
            mock.doSingleThing().waitForSuccess()
        }
    }
    
    func testMockFunctionCompletableReturnsResult() {
        mock.doCompletableThingResult = .success()
        mock.doCompletableThing().waitForCompletion()
    }
    
    func testMockFunctionCompletableTriggersUnexpectedMethodCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedMethodCall(\"AsyncMockTests.doCompletableThing()\") instead") {
            mock.doCompletableThing().waitForCompletion()
        }
    }
    
    func testMockFunctionMaybeReturnsResult() {
        mock.doMaybeThingResult = .success()
        mock.doMaybeThing().waitForCompletion()
    }
    
    func testMockFunctionMaybeReturnsValue() {
        mock.doMaybeThingResult = .value(5)
        let result = mock.doMaybeThing().waitForValue()
        expect(result) == 5
    }
    
    func testMockFunctionMaybeTriggersUnexpectedMethodCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedMethodCall(\"AsyncMockTests.doMaybeThing()\") instead") {
            mock.doMaybeThing().waitForCompletion()
        }
    }
    
    // MARK: - Complex examples
    
}
