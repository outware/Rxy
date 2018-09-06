
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MockResultTests: XCTestCase {
    
    // MARK: - SingleResult
    
    func testSingleResultResolvesError() {
        expect(SingleResult<Int>.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }
    
    func testSingleResultResolvesValue() {
        expect(SingleResult<Int>.value(5).resolve().waitForSuccess()) == 5
    }
    
    func testSingleResultWithOptionalReturnsNilValue() {
        expect(SingleResult<Int?>.value(nil).resolve().waitForSuccess()!).to(beNil())
    }
    
    func testSingleResultResolvesClosure() {
        expect(SingleResult<Int>.value { return 5 }.resolve().waitForSuccess()) == 5
    }
    
    // MARK: - CompletableResult
    
    func testCompletableResultResolvesError() {
        expect(CompletableResult.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }
    
    func testCompletableResultResolvesSuccess() {
        CompletableResult.completed().resolve().waitForCompletion()
    }
    
    // MARK: - MaybeResult
    
    func testMaybeResultResolvesError() {
        expect(MaybeResult<Int>.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }
    
    func testMaybeResultResolvesValue() {
        expect(MaybeResult<Int>.value(5).resolve().waitForValue()) == 5
    }
    
    func testMaybeResultWithOptionalReturnsNilValue() {
        expect(MaybeResult<Int?>.value(nil).resolve().waitForValue()!).to(beNil())
    }
    
    func testMaybeResultResolvesClosure() {
        expect(MaybeResult<Int>.value { return 5 }.resolve().waitForValue()) == 5
    }
    
    func testMaybeResultResolvesSuccess() {
        MaybeResult<Int>.completed().resolve().waitForCompletion()
    }
    
}
