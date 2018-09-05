
//  Copyright © 2018 Derek Clarkson. All rights reserved.

/// Errors that Rxy can generate.
public enum RxyError: Error {
    
    /// Thrown when a result value cannot be cast to the desired type for the Observable.
    case wrongType(expected: Any, found: Any)
    
    /// Thrown when a function is called for which the result is nil.
    case unexpectedFunctionCall(String)
}

//extension RxyError: Equatable {
//    public static func == (lhs: RxyError, rhs: RxyError) -> Bool {
//        switch (lhs, rhs) {
//        case (.wrongType, .wrongType):
//            return true
//        }
//    }
//}

extension Error {
    var typeDescription: String {
        return "\(type(of:self)).\(self)"
    }
}
