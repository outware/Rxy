
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxBlocking
import RxSwift
import Nimble

/// This extension provides wrappers for asynchronous observables which convert them to synchronous and generate Nimble errors
/// if the result is not the expected one.

public extension Observable {
    
    var result: MaterializedSequenceResult<Element> {
        return self.toBlocking().materialize()
    }

    /**
     Waits for an Observable to complete.
     */
    @discardableResult public func waitForCompletion(file: FileString = #file, line: UInt = #line) -> [Element] {
        switch result {
            
        case .failed(elements: _, error: let error):
            fail("Expected successful completion, got a \(error.typeDescription) instead", file: file, line: line)
            return []

        case .completed(elements: let elements):
            return elements
        }
    }
    
    /**
     Waits for an error to be produced.
     
     If the Observable completes without an error, is produced a Nimble failure is generated and a nil returned.
     */
    @discardableResult public func waitForError(file: FileString = #file, line: UInt = #line) -> (error: Error?, values: [Element]) {
        
        switch result {
            
        case .failed(elements: let elements, error: let error):
            return (error: error, values: elements)

        case .completed(elements: let elements):
            fail("Expected an error, but completed instead", file: file, line: line)
            return (error: nil, values: elements)
        }
    }
}
