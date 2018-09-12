
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class SingleResolverTests: XCTestCase {

    func testResolvesError() {
        expect(SingleResolver<Int>(error:TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testResolvesValue() {
        expect(SingleResolver<Int>(value: { 5 }).resolve().waitForSuccess()) == 5
    }

    func testWithOptionalReturnsNilValue() {
        expect(SingleResolver<Int?>(value: { nil }).resolve().waitForSuccess()!).to(beNil())
    }
}
