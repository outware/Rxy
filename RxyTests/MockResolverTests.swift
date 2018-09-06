
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MockResolverTests: XCTestCase {

    // MARK: - SingleResolver

    func testSingleResolverResolvesError() {
        expect(SingleResolver<Int>(error:TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testSingleResolverResolvesValue() {
        expect(SingleResolver<Int>(value: { 5 }).resolve().waitForSuccess()) == 5
    }

    func testSingleResolverWithOptionalReturnsNilValue() {
        expect(SingleResolver<Int?>(value: { nil }).resolve().waitForSuccess()!).to(beNil())
    }

    // MARK: - CompletableResolver

    func testCompletableResolverResolvesError() {
        expect(CompletableResolver(error:TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testCompletableResolverResolvesSuccess() {
        CompletableResolver().resolve().waitForCompletion()
    }
    
    // MARK: - MaybeResolver
    
    func testMaybeResolverResolvesError() {
        expect(MaybeResolver<Int>(error:TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }
    
    func testMaybeResolverResolvesValue() {
        expect(MaybeResolver<Int>(value: { 5 }).resolve().waitForValue()) == 5
    }
    
    func testMaybeResolverWithOptionalReturnsNilValue() {
        expect(MaybeResolver<Int?>(value: { nil }).resolve().waitForValue()!).to(beNil())
    }
    
    func testMaybeResolverResolvesSuccess() {
        MaybeResolver<Int>().resolve().waitForCompletion()
    }
    
}
