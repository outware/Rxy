
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
import Rxy
import RxSwift

class Rx_NimbleTests: XCTestCase {
    
    // MARK: - All Sequences

    func testSequenceWaitForError() {
        expect(Single<Int>.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }

    func testSequenceWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a success instead") {
            Single<Int>.just(5).executeInBackground().waitForError()
        }
    }

    // MARK: - Singles

    func testSingleWaitForSuccess() {
        expect(Single<Int>.just(5).executeInBackground().waitForSuccess()) == 5
    }

    func testSingleWaitForSuccessGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected a single value, got error TestError.anError instead") {
           Single<Int>.error(TestError.anError).executeInBackground().waitForSuccess()
        }
    }

    func testSingleWaitForError() {
        expect(Single<Int>.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }
    
    func testSingleWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a success instead") {
            Single<Int>.just(5).executeInBackground().waitForError()
        }
    }
    
    // MARK: - Maybes
    
    func testMaybeWaitForValue() {
        expect(Maybe<Int>.just(5).executeInBackground().waitForValue()) == 5
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected a value, got error TestError.anError instead") {
            expect(Maybe<Int>.error(TestError.anError).executeInBackground().waitForValue()) == 5
        }
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnCompletion() {
        expectNimble(error: "Expected a value to be returned, but Maybe completed without one") {
            expect(Maybe<Int>.empty().executeInBackground().waitForValue()) == 5
        }
    }

    func testMaybeWaitForCompletion() {
        Maybe<Int>.empty().executeInBackground().waitForCompletion()
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected successful completion, got a TestError.anError instead") {
            Maybe<Int>.error(TestError.anError).executeInBackground().waitForCompletion()
        }
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorWhenValueReturned() {
        expectNimble(error: "Expected successful completion without a value, but had a value returned") {
            Maybe<Int>.just(5).executeInBackground().waitForCompletion()
        }
    }
    
    func testMaybeWaitForError() {
        expect(Maybe<Int>.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }
    
    func testMaybeWaitForErrorGeneratesNimbleErrorOnValue() {
        expectNimble(error: "Expected an error, but Maybe completed instead") {
            Maybe<Int>.just(5).executeInBackground().waitForError()
        }
    }

    func testMaybeWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a value instead") {
            Maybe<Int>.empty().executeInBackground().waitForError()
        }
    }

    // MARK: - Completable
    
    func testCmpletableWaitForCompletion() {
        Completable.empty().executeInBackground().waitForCompletion()
    }

    func testCmpletableWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected successful completion, got a TestError.anError instead") {
            Completable.error(TestError.anError).executeInBackground().waitForCompletion()
        }
    }
    
    func testCompletableWaitForError() {
        expect(Completable.error(TestError.anError).executeInBackground().waitForError()).to(matchError(TestError.anError))
    }
    
    func testCompletableWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but completed instead") {
            Completable.empty().executeInBackground().waitForError()
        }
    }
}
