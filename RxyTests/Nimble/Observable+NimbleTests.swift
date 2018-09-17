
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
import Rxy
import RxSwift

class Observable_NimbleTests: XCTestCase {
    
    func testWaitForCompletion() {
        expect(Observable<Int>.just(5).executeInBackground().waitForCompletion()) == [5]
    }
    
    func testWaitForSuccessGeneratesNimbleErrorOnFailure() {
        expectNimble(error: "Expected successful completion, got a TestError.anError instead") {
            Observable<Int>.error(TestError.anError).executeInBackground().waitForCompletion()
        }
    }
    
    func testWaitForError() {
        let result = Observable<Int>.create { observable in
            observable.on(.next(5))
            observable.on(.error(TestError.anError))
            return Disposables.create()
        }.executeInBackground().waitForError()
        expect(result.error).to(matchError(TestError.anError))
        expect(result.values) == [5]
    }
    
    func testWaitForErrorGeneratesNimbleErrorOnCompletation() {
        expectNimble(error: "Expected an error, but completed instead") {
            Observable<Int>.just(5).executeInBackground().waitForError()
        }
    }
}
