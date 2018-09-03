
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MockResultTests: XCTestCase {

    // MARK: - Completables

//    func testCompletableWaitForErrorReturnsError() {
//        let x: CompletableResult = .throw(RxyError.wrongType)
//        let completable = x.resolve()
//        expect(completable.waitForError()).to(matchError(RxyError.wrongType))
//    }
//
//    func testCompletableWaitForSuccess() {
//        let x: CompletableResult = .success()
//        let completable = x.resolve()
//        completable.waitForCompletion()
//    }

    // MARK: - Singles

    func testSingleWaitForSuccessReturnsError() {
        let x: SingleResult<Int> = .throw(RxyError.wrongType)
        let single = x.resolve()
        expect(single.waitForError()).to(matchError(RxyError.wrongType))
    }

    func testSingleWaitForSuccessReturnsValue() {
        let x: SingleResult<Int> = .value(5)
        let single = x.resolve()
        expect(single.waitForSuccess()) == 5
    }

    func testSingleWaitForSuccessWhenOptionalReturnsNilValue() {
        let x: SingleResult<Int?> = .value(nil)
        let single = x.resolve()
        expect(single.waitForSuccess()!).to(beNil())
    }

    func testSingleWaitForSuccessReturnsValueFromClosure() {
        let x: SingleResult<Int> = .value { return 5 }
        let single = x.resolve()
        expect(single.waitForSuccess()) == 5
    }
}
