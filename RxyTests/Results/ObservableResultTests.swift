
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class ObservableResultTests: XCTestCase {
    
    func testNextValue() {
        expect(ObservableResult<String>.generate { observable in
            observable.on(.next("abc"))
            observable.onCompleted()
        }.resolved.waitForCompletion()) == ["abc"]
    }
    
    func testSuccess() {
        expect(ObservableResult<String>.generate { observable in
            observable.on(.error(TestError.anError))
            }.resolved.waitForError().error).to(matchError(TestError.anError))
    }
}
