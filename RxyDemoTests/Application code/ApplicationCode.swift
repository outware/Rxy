
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

enum TestError: Error {
    case anError
}

// Simple protocol which defines a service we might want to mock out during testing.
protocol HTTPClient {
    func postCompletable(url: String) -> Completable
    func getSingle(url: String) -> Single<RemoteCallResult>
    func doMaybe(url: String) -> Maybe<RemoteCallResult>
}

// Simple object we might return from a call.
struct RemoteCallResult: Decodable {
    var aValue: String?
}

// Simple class which demos the sort of class we might want to test.
class RemoteService {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func makeSingleRemoteCall(toUrl url: String) -> Single<RemoteCallResult> {
        return client.getSingle(url: url)
    }
    
    func makeCompletableRemoteCall(toUrl url: String) -> Completable {
        return client.postCompletable(url: url)
    }
    
    func makeMaybeRemoteCall(toUrl url: String) -> Maybe<RemoteCallResult> {
        return client.doMaybe(url: url)
    }
    
}

