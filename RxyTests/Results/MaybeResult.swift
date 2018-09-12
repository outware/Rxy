
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MaybeResultTests: XCTestCase {

    func testCompletableResultResolvesSuccess() {
        CompletableResult.completed().resolve().waitForCompletion()
    }

    // MARK: - MaybeResult

    func testResolvesError() {
        expect(MaybeResult<Int>.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testResolvesValue() {
        expect(MaybeResult<Int>.value(5).resolve().waitForValue()) == 5
    }

    func testWithOptionalReturnsNilValue() {
        expect(MaybeResult<Int?>.value(nil).resolve().waitForValue()!).to(beNil())
    }

    func testResolvesClosure() {
        expect(MaybeResult<Int>.value { return 5 }.resolve().waitForValue()) == 5
    }

    func testResolvesSuccess() {
        MaybeResult<Int>.completed().resolve().waitForCompletion()
    }

}
