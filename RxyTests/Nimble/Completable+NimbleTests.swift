
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
import Rxy
import RxSwift

class Completable_NimbleTests: XCTestCase {

    func testWaitForCompletion() {
        Completable.empty().executeInBackground().waitForCompletion()
    }

    func testWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected successful completion, got a TestError.anError instead") {
            Completable.error(TestError.anError).executeInBackground().waitForCompletion()
        }
    }

    func testWaitForError() {
        expect(Completable.error(TestError.anError).executeInBackground().waitForError())
            .to(matchError(TestError.anError))
    }

    func testWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but completed instead") {
            Completable.empty().executeInBackground().waitForError()
        }
    }
}
