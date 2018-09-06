
//  Copyright © 2018 Derek Clarkson. All rights reserved.

/// Errors that Rxy can generate.
public enum RxyError: Error {
    
    /// Thrown when a result value cannot be cast to the desired type for the Observable.
    case wrongType(expected: Any, found: Any)
    
    /// Thrown when a function is called for which the result is nil.
    case unexpectedFunctionCall(String)
    
    case invalidJSON

    /// Error decoding JSON into an object.
    case decodingError(expected: Any, fromJSON: String, error: Error)

    /// Should never be thrown.
    case errorNotFound
}

/// Extensions to errors.
extension Error {
    
    /// Used during error reporting, gives a fuller description of the error.
    var typeDescription: String {
        return "\(type(of:self)).\(self)"
    }
}
