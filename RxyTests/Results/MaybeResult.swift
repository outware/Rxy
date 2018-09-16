
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MaybeResultTests: XCTestCase {

    func testCompletableResultResolvesSuccess() {
        CompletableResult.completed().resolved.waitForCompletion()
    }

    // MARK: - MaybeResult

    func testResolvesError() {
        expect(MaybeResult<Int>.throw(TestError.anError).resolved.waitForError()).to(matchError(TestError.anError))
    }

    func testResolvesValue() {
        expect(MaybeResult<Int>.value(5).resolved.waitForValue()) == 5
    }

    func testWithOptionalReturnsNilValue() {
        expect(MaybeResult<Int?>.value(nil).resolved.waitForValue()!).to(beNil())
    }

    func testResolvesClosure() {
        expect(MaybeResult<Int>.value({ return 5 }).resolved.waitForValue()) == 5
    }

    func testResolvesSuccess() {
        MaybeResult<Int>.completed().resolved.waitForCompletion()
    }

}
