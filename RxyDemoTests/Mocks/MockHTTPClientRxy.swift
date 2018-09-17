
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift
import Rxy

/// Same mock class using Rxy to replace the boilerplate.
class MockHTTPClientRxy: BaseMock, HTTPClient {
    
    var postCompletableURL: String?
    var postCompletableURLResult: CompletableResult?
    func postCompletable(url: String) -> Completable {
        postCompletableURL = url
        return mockFunction(returning: postCompletableURLResult)
    }
    
    var getSingleURL: String?
    var getSingleURLResult: SingleResult<RemoteCallResponse>?
    func getSingle(url: String) -> Single<RemoteCallResponse> {
        getSingleURL = url
        return mockFunction(returning: getSingleURLResult)
    }
    
    var doMaybeURL: String?
    var doMaybeURLResult: MaybeResult<RemoteCallResponse>?
    func doMaybe(url: String) -> Maybe<RemoteCallResponse> {
        doMaybeURL = url
        return mockFunction(returning: doMaybeURLResult)
    }

    var doObservableResults: ObservableResult<Int>?
    func doObservable() -> Observable<Int> {
        return mockFunction(returning: doObservableResults)
    }
}
