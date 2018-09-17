
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxBlocking
import RxSwift
import Nimble

/// This extension provides wrappers for asynchronous observables which convert them to synchronous and generate Nimble errors
/// if the result is not the expected one.

public extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {

    /**
     Waits for a Completable to complete.
     */
    public func waitForCompletion(file: FileString = #file, line: UInt = #line) {
        if case let .failed(elements: _, error: error) = result {
            fail("Expected successful completion, got a \(error.typeDescription) instead", file: file, line: line)
        }
    }

    /**
     Waits for an error to be produced.

     If the Completable completes without an error, is produced a Nimble failure is generated and a nil returned.
     */
    @discardableResult public func waitForError(file: FileString = #file, line: UInt = #line) -> Error? {

        if case let .failed(elements: _, error: error) = result {
            return error
        }

        fail("Expected an error, but completed instead", file: file, line: line)
        return nil
    }

}
