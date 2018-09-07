
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Typical mock class where a function can return a variety of results for testing.
class MockHTTPClientOldSchool: HTTPClient {
    
    var postCompletableURL: String?
    var postCompletableURLSuccess: Bool?
    var postCompletableURLError: Error?
    func postCompletable(url: String) -> Completable {
        postCompletableURL = url
        if let _ = postCompletableURLSuccess {
            return Completable.empty()
        }
        if let error = postCompletableURLError {
            return Completable.error(error)
        }
        fatalError("Unexpected method call")
    }
    
    var getSingleURL: String?
    var getSingleURLResult: RemoteCallResult?
    var getSingleURLError: Error?
    func getSingle(url: String) -> Single<RemoteCallResult> {
        getSingleURL = url
        if let result = getSingleURLResult {
            return Single.just(result)
        }
        if let error = getSingleURLError {
            return Single.error(error)
        }
        fatalError("Unexpected method call")
    }
    
    var doMaybeURL: String?
    var doMaybeURLComplete: Bool?
    var doMaybeURLResult: RemoteCallResult?
    var doMaybeURLError: Error?
    func doMaybe(url: String) -> Maybe<RemoteCallResult> {
        doMaybeURL = url
        if let result = doMaybeURLResult {
            return Maybe.just(result)
        }
        if let _ = doMaybeURLComplete {
            return Maybe.empty()
        }
        if let error = doMaybeURLError {
            return Maybe.error(error)
        }
        fatalError("Unexpected method call")
    }
}
