
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy
import RxSwift

class Rx_NimbleTests: XCTestCase {
    
    // MARK: - All Sequences

    func testSequenceWaitForError() {
        expect(Single<Int>.error(RxyError.wrongType).executeInBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testSequenceWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but got a successful completion instead") {
            Single<Int>.just(5).executeInBackground().waitForError()
        }
    }

    // MARK: - Singles

    func testSingleWaitForSuccess() {
        expect(Single<Int>.just(5).executeInBackground().waitForSuccess()) == 5
    }

    func testSingleWaitForSuccessGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected a single value, got error RxyError.wrongType instead") {
           Single<Int>.error(RxyError.wrongType).executeInBackground().waitForSuccess()
        }
    }
    
    // MARK: - Maybes
    
    func testMaybeWaitForValue() {
        expect(Maybe<Int>.just(5).executeInBackground().waitForValue()) == 5
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected a value, got error RxyError.wrongType instead") {
            expect(Maybe<Int>.error(RxyError.wrongType).executeInBackground().waitForValue()) == 5
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
        expectNimble(error: "Expected successful completion, got a RxyError.wrongType instead") {
            Maybe<Int>.error(RxyError.wrongType).executeInBackground().waitForCompletion()
        }
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorWhenValueReturned() {
        expectNimble(error: "Expected successful completion without a value, but had a value returned") {
            Maybe<Int>.just(5).executeInBackground().waitForCompletion()
        }
    }
    
    // MARK: - Completable
    
    func testCmpletableWaitForCompletion() {
        Completable.empty().executeInBackground().waitForCompletion()
    }

    func testCmpletableWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected successful completion, got a RxyError.wrongType instead") {
            Completable.error(RxyError.wrongType).executeInBackground().waitForCompletion()
        }
    }

}
