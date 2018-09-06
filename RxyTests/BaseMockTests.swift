
//  Created by Derek Clarkson on 30/8/18.

import XCTest
import RxSwift
import Nimble
import Rxy

private protocol DoSomething {
    func doSingleThing() -> Single<Int>
}

private class MockSomething: BaseMock {
    
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

class BaseMockTests: XCTestCase {

    func testUnexpectedFunctionPutsErrorOnMockDeclaration() {
        expectNimble(error: "Unexpected function call doUnexpectedFunction()", atLine: #line + 1) {
            let mock = MockSomething()
            mock.doUnexpectedFunction()
        }
    }

    func testCompletableMockErrorPutsErrorOnMockDeclaration() {
        expectNimble(error: "Unexpected function call doCompletableThing()", atLine: #line + 1) {
            let mock = MockSomething()
            mock.doCompletableThing().waitForCompletion()
        }
    }

    func testSingleMockErrorPutsErrorOnMockDeclaration() {
        expectNimble(error: "Unexpected function call doSingleThing()", atLine: #line + 1) {
            let mock = MockSomething()
            mock.doSingleThing().waitForSuccess()
        }
    }

    func testMaybeMockErrorPutsErrorOnMockDeclaration() {
        expectNimble(error: "Unexpected function call doMaybeThing()", atLine: #line + 1) {
            let mock = MockSomething()
            mock.doMaybeThing().waitForValue()
        }
    }

    func testDynamicSingleMockErrorPutsErrorOnMockDeclaration() {
        expectNimble(error: "Unexpected function call doDynamicSingleThing()", atLine: #line + 1) {
            let mock = MockSomething()
            let _: Int? = mock.doDynamicSingleThing().waitForSuccess()
        }
    }

    func testDynamicMaybeMockErrorPutsErrorOnMockDeclaration() {
        expectNimble(error: "Unexpected function call doDynamicMaybeThing()", atLine: #line + 1) {
            let mock = MockSomething()
            let _: Int? = mock.doDynamicMaybeThing().waitForValue()
        }
    }
}
