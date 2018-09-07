
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import RxSwift
import Nimble

import Rxy

// THis test suite shows how Rxy can reduce the size of complex tests.

class RxyDemoComplexTests: XCTestCase {
    
    private var remoteService: RemoteService!
    private var mockHTTPClientOldSchool: MockHTTPClientOldSchool!
    
    override func setUp() {
        super.setUp()
        mockHTTPClientOldSchool = MockHTTPClientOldSchool()
        remoteService = RemoteService(client: mockHTTPClientOldSchool)
    }
   
    func validateSuccess(response: RemoteCallResponse?, line: UInt = #line) {
        expect(self.mockHTTPClientOldSchool.getSingleURL, line: line) == "xyz"
        expect(response?.aValue, line: line) == "abc"
    }
    
    // The basis of this example was a real test in a real project. The reason it's here is to show how Rxy can not only
    // reduce code but make it clearer and easier to understand. In this case the test needed to send 3 calls
    // to the server. Even after reading the comments made by the developer, it wasn't easy to read or understand. Rxy fixed that.
    
    func testComplexRxSwiftCallsUsingSubscribe() {
        
        let disposeBag = DisposeBag()
        var callDone: Bool = false
        
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        remoteService.makeSingleRemoteCall(toUrl: "xyz")
            .asObservable().concatMap { response -> Single<RemoteCallResponse> in
                expect(response.aValue) == "abc"
                self.mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "def")
                return self.remoteService.makeSingleRemoteCall(toUrl: "xyz")
            }
            .asObservable().concatMap { response -> Single<RemoteCallResponse> in
                expect(response.aValue) == "def"
                self.mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "ghi")
                return self.remoteService.makeSingleRemoteCall(toUrl: "xyz")
            }.asSingle()
            .subscribe(
                onSuccess: { response in
                    expect(response.aValue) == "ghi"
                    callDone = true
            },
                onError: { error in
                    fail("Unexpected error \(error)")
                    callDone = true
            }).disposed(by: disposeBag)
        
        expect(callDone).toEventually(beTrue())
    }
    
    // And now using Rxy
    
    func testComplexRxSwiftCallsUsingRxy() {
        
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
        
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "def")
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "def"
        
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "ghi")
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "ghi"
    }
    
}
