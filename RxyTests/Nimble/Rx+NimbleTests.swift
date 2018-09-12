
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
import Rxy
import RxSwift

class Rx_NimbleTests: XCTestCase {
    
    func testSequenceWaitForError() {
        expect(Single<Int>.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }

    func testSequenceWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a success instead") {
            Single<Int>.just(5).executeInBackground().waitForError()
        }
    }
}
