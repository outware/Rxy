
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
import Rxy
import RxSwift

class Single_NimbleTests: XCTestCase {

    func testWaitForSuccess() {
        expect(Single<Int>.just(5).executeInBackground().waitForSuccess()) == 5
    }

    func testWaitForSuccessGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected a single value, got error TestError.anError instead") {
            Single<Int>.error(TestError.anError).executeInBackground().waitForSuccess()
        }
    }

    func testWaitForError() {
        expect(Single<Int>.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }

    func testWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a success instead") {
            Single<Int>.just(5).executeInBackground().waitForError()
        }
    }
}
