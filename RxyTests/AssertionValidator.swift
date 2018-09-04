
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble

fileprivate typealias ErrorLocation = (file: String, line: Int)

/// Quick extension that expects an error to be thrown by Nimble.
extension XCTestCase {
    
    func expectNimble(file: StaticString = #file, line: UInt = #line, error: String, fromBlock block: () -> Void) {
        expectNimble(file: file, line: line, errors: [error], fromBlock: block)
    }

    func expectNimble(file: StaticString = #file, line: UInt = #line, errors: [String], fromBlock block: () -> Void) {

        // Create a Nimble error observer and call the block.
        let handler = AssertionValidator(expectedErrors: errors)
        withAssertionHandler(handler) {
            block()
        }

        // Only display errors if one or more of the expected errors were not found. Extra errors encountered
        // don't trigger this as we are only interested in showing errors when expected ones are not found.
        if !handler.allErrorsFound {
            handler.errors.forEach { keyValue in
                if let location = keyValue.value {
                    self.recordFailure(withDescription: keyValue.key, inFile: location.file, atLine: location.line, expected: true)
                } else {
                    XCTFail("Nimble failure '\(keyValue.key)' not generated in closure", file: file, line: line)
                }
            }
        }
    }
}

/// Implementation of a Nimble AssertionHandler that can be used to capture test failure messages. Note that there is an AssertionRecorder
/// class provided by Nimble that does this, but in this varient we want to ignore all messages if the expected messages are found.
/// This lets us look for specific messages and only display all the messages if one or more are not found.
class AssertionValidator: AssertionHandler {

    private(set) fileprivate var errors:[String: ErrorLocation?] = [:]
    
    public var allErrorsFound: Bool {
        // If any of the errors don't have a location then it was expected but not found.
        for (_, location) in errors {
            if location == nil {
                return false
            }
        }
        return true
    }
    
    init(expectedErrors errors: [String]) {
        // Add expected errors to dictionary with no location.
        errors.forEach { self.errors[$0] = nil as ErrorLocation? } // as? ErrorLocation ensures we add a nil to the dictionary rather than removing the value.
    }
    
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        // Assertion is true if the Nimble assertion passed.
        if !assertion {
            // Add or set the location of the error.
            errors[message.stringValue] = ErrorLocation(file: location.file, line: Int(location.line))
        }
    }
}
