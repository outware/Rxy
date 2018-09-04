
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MockResultTests: XCTestCase {

    // MARK: - SingleResult

    func testSingleResultResolvesError() {
        expect(SingleResult<Int>.throw(RxyError.wrongType).resolve().testInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testSingleResultResolvesValue() {
        expect(SingleResult<Int>.value(5).resolve().testInBackground().waitForSuccess()) == 5
    }

    func testSingleResultWithOptionalReturnsNilValue() {
        expect(SingleResult<Int?>.value(nil).resolve().testInBackground().waitForSuccess()!).to(beNil())
    }

    func testSingleResultResolvesClosure() {
        expect(SingleResult<Int>.value { return 5 }.resolve().testInBackground().waitForSuccess()) == 5
    }
    
    // MARK: - CompletableResult

    func testCompletableResultResolvesError() {
        expect(CompletableResult.throw(RxyError.wrongType).resolve().testInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testCompletableResultResolvesSuccess() {
        CompletableResult.success().resolve().testInBackground().waitForCompletion()
    }
    
    // MARK: - MaybeResult
    
    func testMaybeResultResolvesError() {
        expect(MaybeResult<Int>.throw(RxyError.wrongType).resolve().testInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }
    
    func testMaybeResultResolvesValue() {
        expect(MaybeResult<Int>.value(5).resolve().testInBackground().waitForValue()) == 5
    }
    
    func testMaybeResultWithOptionalReturnsNilValue() {
        expect(MaybeResult<Int?>.value(nil).resolve().testInBackground().waitForValue()!).to(beNil())
    }
    
    func testMaybeResultResolvesClosure() {
        expect(MaybeResult<Int>.value { return 5 }.resolve().testInBackground().waitForValue()) == 5
    }

    func testMaybeResultResolvesSuccess() {
        MaybeResult<Int>.success().resolve().testInBackground().waitForCompletion()
    }
    
}
