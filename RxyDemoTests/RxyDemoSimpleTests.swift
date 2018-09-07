
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import RxSwift
import RxBlocking
import Nimble

import Rxy

/**
 These tests demonstrate the various features of Rxy.
 */

class RxyDemoSimpleTests: XCTestCase {
    
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
    
    // MARK: - Simple example tests showing RxSwift, RxBlocking and Rxy code.
    
    /**
     Rxy's first trick is to replace commonly used boilerplate asynchronous test code when testing RxSwift function calls.
     
     There are two basic ways that these functions are commonly tested. The first is to use RxSwift's subscribe(...) function
     and XCTest's expectations or Nimble's toEventually(...)s to wait for the asynchronous code to execute. The second is to
     make use of RxSwift's RxBlocking framework to effectively convert asynchronous code to a synchrnous execution before making
     expectations.
     
     These tests show both of these solutions, plus the same test written using Rxy's replacement functions.
     */
    
    func testSimpleRxSwiftFunctionUsingSubscribe() {
        
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        
        let disposeBag = DisposeBag()
        var callDone: Bool = false
        var response: RemoteCallResponse?
        remoteService.makeSingleRemoteCall(toUrl: "xyz")
            .subscribe(
                onSuccess: { result in
                    response = result
                    callDone = true
            },
                onError: { error in
                    fail("Unexpected error \(error)")
                    callDone = true
            }).disposed(by: disposeBag)
        
        expect(callDone).toEventually(beTrue())
        validateSuccess(response: response)
    }
    
    func testSimpleRxSwiftFunctionUsingRxBlocking() {
        
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        
        do {
            let response: RemoteCallResponse? = try remoteService.makeSingleRemoteCall(toUrl: "xyz").toBlocking().first()
            validateSuccess(response: response)
        }
        catch let error {
            fail("Unexpected error \(error)")
        }
    }
    
    func testSimpleRxSwiftFunctionUsingRxy() {
        mockHTTPClientOldSchool.getSingleURLResult = RemoteCallResponse(aValue: "abc")
        let response: RemoteCallResponse? = remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()
        validateSuccess(response: response)
    }
}
