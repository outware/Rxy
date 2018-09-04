
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy
import RxSwift

class Rx_NimbleTests: XCTestCase {
    
    // MARK: - All Sequences

    func testSequenceWaitForError() {
        expect(Single<Int>.error(RxyError.wrongType).testInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testSequenceWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(failure: "Expected an error, but got a successful completion instead") {
            Single<Int>.just(5).testInBackground().waitForError()
        }
    }

    // MARK: - Singles

    func testSingleWaitForSuccess() {
        expect(Single<Int>.just(5).testInBackground().waitForSuccess()) == 5
    }

    func testSingleWaitForSuccessGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected a single value, got error RxyError.wrongType instead") {
           Single<Int>.error(RxyError.wrongType).testInBackground().waitForSuccess()
        }
    }
    
    // MARK: - Maybes
    
    func testMaybeWaitForValue() {
        expect(Maybe<Int>.just(5).testInBackground().waitForValue()) == 5
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected a value, got error RxyError.wrongType instead") {
            expect(Maybe<Int>.error(RxyError.wrongType).testInBackground().waitForValue()) == 5
        }
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnCompletion() {
        expectNimble(failure: "Expected a value to be returned, but Maybe completed without one") {
            expect(Maybe<Int>.empty().testInBackground().waitForValue()) == 5
        }
    }

    func testMaybeWaitForCompletion() {
        Maybe<Int>.empty().testInBackground().waitForCompletion()
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected successful completion, got a RxyError.wrongType instead") {
            Maybe<Int>.error(RxyError.wrongType).testInBackground().waitForCompletion()
        }
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorWhenValueReturned() {
        expectNimble(failure: "Expected successful completion without a value, but had a value returned") {
            Maybe<Int>.just(5).testInBackground().waitForCompletion()
        }
    }
    
    // MARK: - Completable
    
    func testCmpletableWaitForCompletion() {
        Completable.empty().testInBackground().waitForCompletion()
    }

    func testCmpletableWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected successful completion, got a RxyError.wrongType instead") {
            Completable.error(RxyError.wrongType).testInBackground().waitForCompletion()
        }
    }

}
