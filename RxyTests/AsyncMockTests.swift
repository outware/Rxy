
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
    
    // MARK: Dynamic results
    
    var doDynamicSingleThingResult: SingleResult<Any>?
    func doDynamicSingleThing<T>() -> Single<T> {
        return mockFunction(returning: doDynamicSingleThingResult)
    }

    var doDynamicMaybeThingResult: MaybeResult<Any>?
    func doDynamicMaybeThing<T>() -> Maybe<T> {
        return mockFunction(returning: doDynamicMaybeThingResult)
    }
}

class AsyncMockTests: XCTestCase {
    
    private var mock: MockSomething!
    
    override func setUp() {
        mock = MockSomething()
    }
    
    // MARK: - Core tests
    
    func testUnexpectedMethodCalled() {
        expectNimble(error: "Unexpected function call doUnexpectedMethod()") {
            mock.doUnexpectedMethod()
        }
    }
    
    func testMockFunctionSingleReturnsResult() {
        mock.doSingleThingResult = .value(5)
        let result = mock.doSingleThing().waitForSuccess()
        expect(result) == 5
    }
    
    func testMockFunctionSingleTriggersUnexpectedMethodCall() {
        expectNimble(error: "Expected a single value, got error RxyError.unexpectedMethodCall(\"doSingleThing()\") instead") {
            mock.doSingleThing().waitForSuccess()
        }
    }
    
    func testMockFunctionCompletableReturnsResult() {
        mock.doCompletableThingResult = .success()
        mock.doCompletableThing().waitForCompletion()
    }
    
    func testMockFunctionCompletableTriggersUnexpectedMethodCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedMethodCall(\"doCompletableThing()\") instead") {
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
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedMethodCall(\"doMaybeThing()\") instead") {
            mock.doMaybeThing().waitForCompletion()
        }
    }
    
    // MARK: - Complex examples

    func testDynamicSingleExample() {

        // First a int
        mock.doDynamicSingleThingResult = .value(5)
        let result1: Int? = mock.doDynamicSingleThing().waitForSuccess()
        expect(result1) == 5

        // Then a string
        mock.doDynamicSingleThingResult = .value("abc")
        let result2: String? = mock.doDynamicSingleThing().waitForSuccess()
        expect(result2) == "abc"
    }

    func testDynamicSingleExampleWithTypeCastFailure() {
        
        mock.doDynamicSingleThingResult = .value("abc")
        
        expectNimble(error: "Expected a single value, got error RxyError.wrongType(expected: Swift.Int, found: Swift.String) instead") {
            let _: Int? = mock.doDynamicSingleThing().waitForSuccess()
        }
    }
    
    func testDynamicMaybeExample() {
        
        // First a int
        mock.doDynamicMaybeThingResult = .value(5)
        let result1: Int? = mock.doDynamicMaybeThing().waitForValue()
        expect(result1) == 5
        
        // Then a string
        mock.doDynamicMaybeThingResult = .value("abc")
        let result2: String? = mock.doDynamicMaybeThing().waitForValue()
        expect(result2) == "abc"
    }
    
    func testDynamicMaybeExampleWithTypeCastFailure() {
        
        mock.doDynamicMaybeThingResult = .value("abc")
        
        expectNimble(error: "Expected a value, got error RxyError.wrongType(expected: Swift.Int, found: Swift.String) instead") {
            let _: Int? = mock.doDynamicMaybeThing().waitForValue()
        }
    }


}
