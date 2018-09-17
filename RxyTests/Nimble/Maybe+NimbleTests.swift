
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
import Rxy
import RxSwift

class Maybe_NimbleTests: XCTestCase {

    func testWaitForValue() {
        expect(Maybe<Int>.just(5).executeInBackground().waitForValue()) == 5
    }

    func testWaitForValueGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected a value, got error TestError.anError instead") {
            expect(Maybe<Int>.error(TestError.anError).executeInBackground().waitForValue()) == 5
        }
    }

    func testWaitForValueGeneratesNimbleErrorOnCompletion() {
        expectNimble(error: "Expected a value to be returned, but Maybe completed without one") {
            expect(Maybe<Int>.empty().executeInBackground().waitForValue()) == 5
        }
    }

    func testWaitForCompletion() {
        Maybe<Int>.empty().executeInBackground().waitForCompletion()
    }

    func testWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected successful completion, got a TestError.anError instead") {
            Maybe<Int>.error(TestError.anError).executeInBackground().waitForCompletion()
        }
    }

    func testWaitForCompletionGeneratesNimbleErrorWhenValueReturned() {
        expectNimble(error: "Expected successful completion without a value, but had a value returned") {
            Maybe<Int>.just(5).executeInBackground().waitForCompletion()
        }
    }

    func testWaitForError() {
        expect(Maybe<Int>.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }

    func testWaitForErrorGeneratesNimbleErrorOnValue() {
        expectNimble(error: "Expected an error, but Maybe completed instead") {
            Maybe<Int>.just(5).executeInBackground().waitForError()
        }
    }

    func testWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a value instead") {
            Maybe<Int>.empty().executeInBackground().waitForError()
        }
    }
}
