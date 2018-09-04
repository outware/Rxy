
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift
import Nimble

protocol AsyncMock {}

extension AsyncMock {
    
    func unexpectedFunctionCall(mockedInFile: String = #file, mockedAtLine: UInt = #line, mockedFunction: String) {
        fail("Unexpected function call \(mockedFunction)", file: mockedInFile, line: mockedAtLine)
    }

    func mockFunction<T>(mockedInFile: String = #file, mockedAtLine: UInt = #line, mockedFunction: String = #function, returning result: SingleResult<T>?) -> Single<T> {
        guard let result = result else {
            unexpectedFunctionCall(mockedInFile: mockedInFile, mockedAtLine: mockedAtLine, mockedFunction: mockedFunction)
            return Single<T>.error(RxyError.unexpectedMethodCall)
        }
        return result.resolve().executeInBackground()
    }
}
