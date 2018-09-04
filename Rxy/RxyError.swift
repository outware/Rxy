
//  Copyright © 2018 Derek Clarkson. All rights reserved.

public enum RxyError: Error {
    case wrongType
    case unexpectedMethodCall
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
