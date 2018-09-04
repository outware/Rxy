
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MockResultTests: XCTestCase {

    // MARK: - SingleResult

    func testSingleResultResolvesError() {
        expect(SingleResult<Int>.throw(RxyError.wrongType).resolve().executeInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testSingleResultResolvesValue() {
        expect(SingleResult<Int>.value(5).resolve().executeInBackground().waitForSuccess()) == 5
    }

    func testSingleResultWithOptionalReturnsNilValue() {
        expect(SingleResult<Int?>.value(nil).resolve().executeInBackground().waitForSuccess()!).to(beNil())
    }

    func testSingleResultResolvesClosure() {
        expect(SingleResult<Int>.value { return 5 }.resolve().executeInBackground().waitForSuccess()) == 5
    }
    
    // MARK: - CompletableResult

    func testCompletableResultResolvesError() {
        expect(CompletableResult.throw(RxyError.wrongType).resolve().executeInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testCompletableResultResolvesSuccess() {
        CompletableResult.success().resolve().executeInBackground().waitForCompletion()
    }
    
    // MARK: - MaybeResult
    
    func testMaybeResultResolvesError() {
        expect(MaybeResult<Int>.throw(RxyError.wrongType).resolve().executeInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }
    
    func testMaybeResultResolvesValue() {
        expect(MaybeResult<Int>.value(5).resolve().executeInBackground().waitForValue()) == 5
    }
    
    func testMaybeResultWithOptionalReturnsNilValue() {
        expect(MaybeResult<Int?>.value(nil).resolve().executeInBackground().waitForValue()!).to(beNil())
    }
    
    func testMaybeResultResolvesClosure() {
        expect(MaybeResult<Int>.value { return 5 }.resolve().executeInBackground().waitForValue()) == 5
    }

    func testMaybeResultResolvesSuccess() {
        MaybeResult<Int>.success().resolve().executeInBackground().waitForCompletion()
    }
    
}
