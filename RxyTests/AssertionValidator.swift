
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble

// MARK: - Testing support code

/// Class which is used to track and report on the status of Nimble errors encountered in a closure.
class SearchCriteria {
    
    let error: String
    var expectedError: Bool = false
    var expectedLine: Int?
    var foundLine: Int?
    var errorMatcher: (String, String) -> Bool = { $0 == $1 }
    
    init(error: String, foundAtLine line: Int) {
        self.error = error
        self.foundLine = line
    }
    
    init(error: String, expectedAtLine line: Int?) {
        self.expectedError = true
        self.error = error
        self.expectedLine = line
    }
    
    func errorFound(atLine line: Int) {
        self.foundLine = line
    }
    
    func matches(_ error: String) -> Bool {
        return errorMatcher(error, self.error)
    }
    
    func report(inTestcase testcase: XCTestCase, nimbleExpectAtLine: Int, inSourceFile sourceFile: String) {
        
        switch (foundLine, expectedLine, expectedError) {
            
        case (.some(let found), .some(let expected), _) where found != expected: // Found on wrong line.
            testcase.recordFailure(withDescription: "Nimble failure '\(error)' found on line \(found), but expected to be on line \(expected)",
                inFile: sourceFile,
                atLine: found,
                expected: true)
            
        case (.some(let found), .none, false): // Unexpected found on any line.
            testcase.recordFailure(withDescription: error, inFile: sourceFile, atLine: found, expected: true)
            
        case(.none, .some(let expected), true): // Expected message on a particular line, but was not found.
            testcase.recordFailure(withDescription: "Nimble failure '\(error)' expected, but not generated",
                inFile: sourceFile,
                atLine: expected,
                expected: true)
            
        case(.none, .none, true): // Expected message, but was not found.
            testcase.recordFailure(withDescription: "Nimble failure '\(error)' expected, but not generated",
                inFile: sourceFile,
                atLine: nimbleExpectAtLine,
                expected: true)
            
        default:
            // Expected and found. Good.
            break
        }
    }
}

typealias Criteria = (error: String, line: Int?, matcher: ((String, String) -> Bool)?)

/// Quick extension that expects an error to be thrown by Nimble.
extension XCTestCase {
    
    /**
     Expected the passed closure to generate an error.
     
     Optionally can also specify the line where the error is expected to be placed by Nimble.
     
     - Parameter file: The test case file. Defaults to #file.
     - Parameter line: The line where this function resides. Defaults to #line.
     - Parameter error: The error that is expected to be generated.
     - Parameter atLine: Optional line number where the Nimble error is expected to appear.
     - Parameter usingMatcher: A matcher closure that will match an error. By default this is a simple x == y expression.
     - Parameter fromClosure: The closure that is expected to generate the error.
     */
    func expectNimble(file: StaticString = #file,
                      line: UInt = #line,
                      error: String,
                      atLine: Int? = nil,
                      usingMatcher matcher: ((String, String) -> Bool)? = nil,
                      fromClosure closure: () -> Void) {
        expectNimble(file: file, line: line, criteria: [Criteria(error: error, line: atLine, matcher: matcher)], fromClosure: closure)
    }
    
    /**
     Expected the passed closure to generate one or more errors.
     
     Optionally can also specify the line where the error is expected to be placed by Nimble.
     
     - Parameter file: The test case file. Defaults to #file.
     - Parameter line: The line where this function resides. Defaults to #line.
     - Parameter criteria: One or more criteria instances which define the expected errors.
     - Parameter fromClosure: The closure that is expected to generate the error.
     */
    func expectNimble(file: StaticString = #file, line: UInt = #line, criteria: [Criteria], fromClosure closure: () -> Void) {
        
        // Create a Nimble error observer and call the closure.
        let expectedErrors = criteria.map { criteria -> SearchCriteria in
            let expected = SearchCriteria(error: criteria.error, expectedAtLine: criteria.line)
            if let matcher = criteria.matcher {
                expected.errorMatcher = matcher
            }
            return expected
        }

        let handler = AssertionValidator(expectedErrors: expectedErrors, nimbleExpectLine: Int(line), inSourceFile: String(describing: file))
        withAssertionHandler(handler) {
            closure()
        }
        
        handler.report(toTestCase: self)
        
    }
}

/// Implementation of a Nimble AssertionHandler that can be used to capture test failure messages. Note that there is an AssertionRecorder
/// class provided by Nimble that does this, but in this varient we want to ignore all messages if the expected messages are found.
/// This lets us look for specific messages and only display all the messages if one or more are not found.
class AssertionValidator: AssertionHandler {
    
    private(set) fileprivate var errors:[SearchCriteria] = []
    private let sourceFile: String
    private let nimbleExpectLine: Int
    
    init(expectedErrors errors: [SearchCriteria], nimbleExpectLine: Int, inSourceFile sourceFile: String) {
        self.errors = errors
        self.sourceFile = sourceFile
        self.nimbleExpectLine = nimbleExpectLine
    }
    
    func report(toTestCase testCase: XCTestCase) {
        // Only display errors if one or more of the expected errors were not found. Extra errors encountered
        // don't trigger this as we are only interested in showing errors when expected ones are not found.
        let reportErrors = errors.contains { $0.foundLine == nil && $0.expectedError }
        if reportErrors {
            errors.forEach { $0.report(inTestcase: testCase, nimbleExpectAtLine: nimbleExpectLine, inSourceFile: sourceFile) }
        }
    }
    
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        
        // Assertion is true if the Nimble assertion passed.
        if !assertion {
            // Add or set the location of the error.
            if let error = errors.first(where:{ $0.matches(message.stringValue) }) {
                error.errorFound(atLine: Int(location.line))
            } else {
                errors.append(SearchCriteria(error: message.stringValue, foundAtLine: Int(location.line)))
            }
        }
    }
}
