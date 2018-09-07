
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift
import Rxy

/// Same mock class using Rxy to replace the boilerplate.
class MockHTTPClientRxy: BaseMock, HTTPClient {
    
    var postCompletableURL: String?
    var postCompletableURLResult: CompletableResult?
    func postCompletable(url: String) -> Completable {
        return mockFunction(returning: postCompletableURLResult)
    }
    
    var getSingleURL: String?
    var getSingleURLResult: SingleResult<RemoteCallResult>?
    func getSingle(url: String) -> Single<RemoteCallResult> {
        return mockFunction(returning: getSingleURLResult)
    }
    
    var doMaybeURL: String?
    var doMaybeURLResult: MaybeResult<RemoteCallResult>?
    func doMaybe(url: String) -> Maybe<RemoteCallResult> {
        return mockFunction(returning: doMaybeURLResult)
    }
}
