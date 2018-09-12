
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class CompletableResolverTests: XCTestCase {

    func testResolvesError() {
        expect(CompletableResolver(error:TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testResolvesSuccess() {
        CompletableResolver().resolve().waitForCompletion()
    }
    
}
