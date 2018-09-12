
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MaybeResolverTests: XCTestCase {

    // MARK: - MaybeResolver

    func testResolvesError() {
        expect(MaybeResolver<Int>(error:TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testResolvesValue() {
        expect(MaybeResolver<Int>(value: { 5 }).resolve().waitForValue()) == 5
    }

    func testWithOptionalReturnsNilValue() {
        expect(MaybeResolver<Int?>(value: { nil }).resolve().waitForValue()!).to(beNil())
    }

    func testResolvesSuccess() {
        MaybeResolver<Int>().resolve().waitForCompletion()
    }

}
