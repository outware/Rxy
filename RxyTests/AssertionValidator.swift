
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble

fileprivate typealias RecordedError = (error: String, file: String, line: Int)

/// Quick extension that expects an error to be thrown by Nimble.
extension XCTestCase {
    
    func expectNimble(file: StaticString = #file, line: UInt = #line, failure error: String, fromBlock block: () -> Void) {

        let handler = AssertionValidator(expectedError: error)
        withAssertionHandler(handler) {
            block()
        }

        if !handler.errorFound {
            handler.errors.forEach { error in
                self.recordFailure(withDescription: error.error, inFile: error.file, atLine: error.line, expected: true)
            }
            XCTFail("Nimble failure '\(error)' not generated in closure", file: file, line: line)
        }
    }
}

/// Implementation of a Nimble AssertionHandler that can be used to capture test failure messages. Note that there is an AssertionRecorder
/// class provided by Nimble that does this, but in this varient we want to ignore any messages that match the type we are looking for.
class AssertionValidator: AssertionHandler {

    private let expectedError: String
    private(set) fileprivate var errors:[RecordedError] = []
    
    public var errorFound: Bool = false
    
    init(expectedError error: String) {
        self.expectedError = error
    }
    
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            if message.stringValue == expectedError {
                errorFound = true
            } else {
                errors.append(RecordedError(error: message.stringValue, file: location.file, line: Int(location.line)))
            }
        }
    }
}
