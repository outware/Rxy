
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxBlocking
import RxSwift
import Nimble

/// This extension provides wrappers for asynchronous observables which convert them to synchronous and generate Nimble errors
/// if the result is not the expected one.

public extension PrimitiveSequence where Trait == MaybeTrait {

    /**
     Waits for the Meybe to complete without producing a value.

     If a value is produced or an error is returned, this function will geneerate an appropriate Nimble failure.
     */
    public func waitForCompletion(file: FileString = #file, line: UInt = #line) {

        switch result {

        case .failed(elements: _, error: let error):
            fail("Expected successful completion, got a \(error.typeDescription) instead", file: file, line: line)

        case .completed(elements: let elements):
            if !elements.isEmpty {
                fail("Expected successful completion without a value, but had a value returned", file: file, line: line)
            }
        }
    }

    /**
     Waits for the Maybe to produce a value.

     If an error is returned or the Maybe completes without a value then a Nimble failure is generated.
     */
    @discardableResult public func waitForValue(file: FileString = #file, line: UInt = #line) -> Element? {

        switch result {

        case .completed(elements: let elements):
            if elements.isEmpty {
                fail("Expected a value to be returned, but Maybe completed without one", file: file, line: line)
                return nil
            }
            return elements.first!

        case .failed(elements: _, error: let error):
            fail("Expected a value, got error \(error.typeDescription) instead", file: file, line: line)
            return nil
        }
    }

    /**
     Waits for an error to be produced.

     If the Maybe completes without an error, is produced a Nimble failure is generated and a nil returned.
     */
    @discardableResult public func waitForError(file: FileString = #file, line: UInt = #line) -> Error? {

        switch result {
        case .failed(elements: _, error: let error):
            return error

        case .completed(elements: let elements):
            if elements.isEmpty {
                fail("Expected an error, but got a value instead", file: file, line: line)
                return nil
            }
            fail("Expected an error, but Maybe completed instead", file: file, line: line)
            return nil
        }
    }
}
