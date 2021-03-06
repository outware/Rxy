
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
    var getSingleURLResult: RemoteCallResponse?
    var getSingleURLError: Error?
    func getSingle(url: String) -> Single<RemoteCallResponse> {
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
    var doMaybeURLResult: RemoteCallResponse?
    var doMaybeURLError: Error?
    func doMaybe(url: String) -> Maybe<RemoteCallResponse> {
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

    var doObservableResults: [Int]?
    var doObservableError: Error?
    func doObservable() -> Observable<Int> {
        guard doObservableResults != nil || doObservableError != nil else {
            fatalError("Unexpected method call")
        }
        return Observable<Int>.create { observable in
            if let results = self.doObservableResults {
                results.forEach { observable.on(.next($0)) }
                observable.on(.completed)
            }
            if let error = self.doObservableError {
                observable.on(.error(error))
            }
            return Disposables.create()
        }
    }
}
