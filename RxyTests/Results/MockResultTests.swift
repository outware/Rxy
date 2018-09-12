
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class SingleResultTests: XCTestCase {
    
    func testResolvesError() {
        expect(SingleResult<Int>.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }
    
    func testResolvesValue() {
        expect(SingleResult<Int>.value(5).resolve().waitForSuccess()) == 5
    }
    
    func testWithOptionalReturnsNilValue() {
        expect(SingleResult<Int?>.value(nil).resolve().waitForSuccess()!).to(beNil())
    }
    
    func testResolvesClosure() {
        expect(SingleResult<Int>.value { return 5 }.resolve().waitForSuccess()) == 5
    }

}
