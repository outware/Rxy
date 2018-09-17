
//  Created by Derek Clarkson on 30/8/18.

import XCTest
import RxSwift
import Nimble
import Rxy

private class MockSomething: AsyncMock {
    
    func doUnexpectedFunction() {
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

    var doObservableThingResult: ObservableResult<Int>?
    func doObservableThing() -> Observable<Int> {
        return mockFunction(returning: doObservableThingResult)
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
    
    var doDynamicObservableThingResult: ObservableResult<Any>?
    func doDynamicObservableThing<T>() -> Observable<T> {
        return mockFunction(returning: doDynamicObservableThingResult)
    }

}

class AsyncMockTests: XCTestCase {
    
    private var mock: MockSomething!
    
    override func setUp() {
        mock = MockSomething()
    }
    
    // MARK: - Core tests
    
    func testUnexpectedFunctionCalled() {
        expectNimble(error: "Unexpected function call doUnexpectedFunction()") {
            mock.doUnexpectedFunction()
        }
    }
    
    func testMockFunctionSingleReturnsResult() {
        mock.doSingleThingResult = .value(5)
        let result = mock.doSingleThing().waitForSuccess()
        expect(result) == 5
    }

    func testMockFunctionSingleReturnsError() {
        mock.doSingleThingResult = .throw(TestError.anError)
        expect(self.mock.doSingleThing().waitForError()).to(matchError(TestError.anError))
    }

    func testMockFunctionSingleTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected a single value, got error RxyError.unexpectedFunctionCall(\"doSingleThing()\") instead") {
            mock.doSingleThing().waitForSuccess()
        }
    }
    
    func testMockFunctionCompletableReturnsResult() {
        mock.doCompletableThingResult = .completed()
        mock.doCompletableThing().waitForCompletion()
    }
    
    func testMockFunctionCompletableTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedFunctionCall(\"doCompletableThing()\") instead") {
            mock.doCompletableThing().waitForCompletion()
        }
    }
    
    func testMockFunctionMaybeReturnsResult() {
        mock.doMaybeThingResult = .completed()
        mock.doMaybeThing().waitForCompletion()
    }
    
    func testMockFunctionMaybeReturnsValue() {
        mock.doMaybeThingResult = .value(5)
        let result = mock.doMaybeThing().waitForValue()
        expect(result) == 5
    }
    
    func testMockFunctionMaybeTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedFunctionCall(\"doMaybeThing()\") instead") {
            mock.doMaybeThing().waitForCompletion()
        }
    }

    func testMockFunctionObservableGeneratesResult() {
        mock.doObservableThingResult = .generate { observable in
            observable.on(.next(1))
            observable.on(.next(2))
            observable.on(.next(3))
            observable.on(.completed)
        }
        mock.doObservableThing().waitForCompletion()
    }
    
    func testMockFunctionObservableReturnsValue() {
        mock.doObservableThingResult = .sequence([1,2,3])
        let result = mock.doObservableThing().waitForCompletion()
        expect(result) == [1,2,3]
    }
    
    func testMockFunctionObservableTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedFunctionCall(\"doObservableThing()\") instead") {
            mock.doObservableThing().waitForCompletion()
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
    
    func testDynamicSingleExampleTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected a single value, got error RxyError.unexpectedFunctionCall(\"doDynamicSingleThing()\") instead") {
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
    
    func testDynamicMaybeExampleTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected a value, got error RxyError.unexpectedFunctionCall(\"doDynamicMaybeThing()\") instead") {
            let _: Int? = mock.doDynamicMaybeThing().waitForValue()
        }
    }

    func testDynamicObservableExample() {
        
        // First a int
        mock.doDynamicObservableThingResult = .sequence([1,2,3])
        let result1: [Int]? = mock.doDynamicObservableThing().waitForCompletion()
        expect(result1) == [1,2,3]
        
        // Then a string
        mock.doDynamicObservableThingResult = .sequence(["abc", "def"])
        let result2: [String]? = mock.doDynamicObservableThing().waitForCompletion()
        expect(result2) == ["abc", "def"]
    }
    
    func testDynamicObservableExampleWithTypeCastFailure() {
        
        mock.doDynamicObservableThingResult = .sequence([1,2,3])
        
        expectNimble(error: "Expected successful completion, got a RxyError.wrongType(expected: Swift.String, found: Swift.Int) instead") {
            let _: [String]? = mock.doDynamicObservableThing().waitForCompletion()
        }
    }
    
    func testDynamicObservableExampleTriggersUnexpectedFunctionCall() {
        expectNimble(error: "Expected successful completion, got a RxyError.unexpectedFunctionCall(\"doDynamicObservableThing()\") instead") {
            let _: [Int]? = mock.doDynamicObservableThing().waitForCompletion()
        }
    }
}
