
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MockResultTests: XCTestCase {

    // MARK: - SingleResult

    func testSingleResultResolvesError() {
        expect(SingleResult<Int>.throw(TestError.anError).resolve().executeInBackground().waitForError()).to(matchError(TestError.anError))
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
        expect(CompletableResult.throw(TestError.anError).resolve().executeInBackground().waitForError()).to(matchError(TestError.anError))
    }

    func testCompletableResultResolvesSuccess() {
        CompletableResult.success().resolve().executeInBackground().waitForCompletion()
    }
    
    // MARK: - MaybeResult
    
    func testMaybeResultResolvesError() {
        expect(MaybeResult<Int>.throw(TestError.anError).resolve().executeInBackground().waitForError()).to(matchError(TestError.anError))
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
