
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy
import RxSwift

class Rx_NimbleTests: XCTestCase {
    
    // MARK: - All Sequences

    func testSequenceWaitForError() {
        expect(Single<Int>.error(RxyError.wrongType).inBackground().waitForError()).to(matchError(RxyError.wrongType))
    }

    func testSequenceWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(failure: "Expected an error, but got a successful completion instead") {
            Single<Int>.just(5).inBackground().waitForError()
        }
    }

    // MARK: - Singles

    func testSingleWaitForSuccess() {
        expect(Single<Int>.just(5).inBackground().waitForSuccess()) == 5
    }

    func testSingleWaitForSuccessGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected a single value, got error RxyError.wrongType instead") {
           Single<Int>.error(RxyError.wrongType).inBackground().waitForSuccess()
        }
    }
    
    // MARK: - Maybes
    
    func testMaybeWaitForValue() {
        expect(Maybe<Int>.just(5).inBackground().waitForValue()) == 5
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected a value, got error RxyError.wrongType instead") {
            expect(Maybe<Int>.error(RxyError.wrongType).inBackground().waitForValue()) == 5
        }
    }

    func testMaybeWaitForValueGeneratesNimbleErrorOnCompletion() {
        expectNimble(failure: "Expected a value to be returned, but Maybe completed without one") {
            expect(Maybe<Int>.empty().inBackground().waitForValue()) == 5
        }
    }

    func testMaybeWaitForCompletion() {
        Maybe<Int>.empty().inBackground().waitForCompletion()
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected successful completion, got a RxyError.wrongType instead") {
            Maybe<Int>.error(RxyError.wrongType).inBackground().waitForCompletion()
        }
    }

    func testMaybeWaitForCompletionGeneratesNimbleErrorWhenValueReturned() {
        expectNimble(failure: "Expected successful completion without a value, but had a value returned") {
            Maybe<Int>.just(5).inBackground().waitForCompletion()
        }
    }
    
    // MARK: - Completable
    
    func testCmpletableWaitForCompletion() {
        Completable.empty().inBackground().waitForCompletion()
    }

    func testCmpletableWaitForCompletionGeneratesNimbleErrorOnFailure() {
        expectNimble(failure: "Expected successful completion, got a RxyError.wrongType instead") {
            Completable.error(RxyError.wrongType).inBackground().waitForCompletion()
        }
    }

}
