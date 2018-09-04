
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Base class for mocks that provides the file and line where the mock was created. This can simply a lot of mock code.
class BaseMock: AsyncMock {
    
    private let mockedInFile: String
    private let mockedAtLine: UInt
    
    init(file: String = #file, line: UInt = #line) {
        self.mockedInFile = file
        self.mockedAtLine = line
    }
    
    func mockFunction<T>(mockedFunction: String = #function, returning result: SingleResult<T>?) -> Single<T> {
        return mockFunction(file: mockedInFile, line: mockedAtLine, function: mockedFunction, returning: result)
    }
}
