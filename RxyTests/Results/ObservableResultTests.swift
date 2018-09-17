
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class ObservableResultTests: XCTestCase {
    
    func testGenerateNextValue() {
        expect(ObservableResult<String>.generate { observable in
            observable.on(.next("abc"))
            observable.onCompleted()
        }.resolve().waitForCompletion()) == ["abc"]
    }
    
    func testGenerateError() {
        expect(ObservableResult<String>.generate { observable in
            observable.on(.error(TestError.anError))
            }.resolve().waitForError().error).to(matchError(TestError.anError))
    }
    
    func testSequence() {
        expect(ObservableResult<Int>.sequence([1,2,3]).resolve().waitForCompletion()) == [1,2,3]
    }

    func testThrow() {
        expect(ObservableResult<String>.throw(TestError.anError).resolve().waitForError().error).to(matchError(TestError.anError))
    }

}
