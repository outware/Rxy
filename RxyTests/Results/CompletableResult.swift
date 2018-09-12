
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class CompletableResultTests: XCTestCase {

    func testResolvesError() {
        expect(CompletableResult.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testResolvesSuccess() {
        CompletableResult.completed().resolve().waitForCompletion()
    }

}
