
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxBlocking
import RxSwift
import Nimble

/// This extension provides wrappers for asynchronous observables which convert them to synchronous and generate Nimble errors
/// if the result is not the expected one.

public extension PrimitiveSequence where Trait == SingleTrait {

    /**
     Waits for a single to succeed.

     If an error is produced instead, a Nimble failure is genrated and a nil returned.
     */
    @discardableResult public func waitForSuccess(file: FileString = #file, line: UInt = #line) -> Element? {

        switch result {

        case .completed(elements: let elements):
            return elements.first!

        case .failed(elements: _, error: let error):
            fail("Expected a single value, got error \(error.typeDescription) instead", file: file, line: line)
            return nil
        }
    }

    /**
     Waits for an error to be produced.

     If the Single completes without an error, is produced a Nimble failure is generated and a nil returned.
     */
    @discardableResult public func waitForError(file: FileString = #file, line: UInt = #line) -> Error? {

        if case let .failed(elements: _, error: error) = result {
            return error
        }

        fail("Expected an error, but got a success instead", file: file, line: line)
        return nil
    }
}
