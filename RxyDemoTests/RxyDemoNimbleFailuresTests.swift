
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Rxy
import Nimble

// These tests show the sorts of errors that Rxy can generate.

class RxyDemoNimbleFailuresTests: XCTestCase {
    
    private var remoteService: RemoteService!
    private var mockHTTPClientRxy: MockHTTPClientRxy!
    
    override func setUp() {
        super.setUp()
        mockHTTPClientRxy = MockHTTPClientRxy()
        remoteService = RemoteService(client: mockHTTPClientRxy)
    }
    
    // MARK; - Completables
    
    func testCompletableWaitForCompletion_failure() {
        mockHTTPClientRxy.postCompletableURLResult = .throw(TestError.anError)
        self.remoteService.makeCompletableRemoteCall(toUrl: "xyz").waitForCompletion()
    }
    
    func testCompletableWaitForError_failure() {
        mockHTTPClientRxy.postCompletableURLResult = .completed()
        expect(self.remoteService.makeCompletableRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
    // MARK: - Singles
    
    func testSingleWaitForSuccess_failure() {
        mockHTTPClientRxy.getSingleURLResult = .throw(TestError.anError)
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
    }
    
    func testSingleWaitForError_failure() {
        mockHTTPClientRxy.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
    // MARK: - Maybes
    
    func testMaybeWaitForValue_failureWithError() {
        mockHTTPClientRxy.doMaybeURLResult = .throw(TestError.anError)
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForValue()?.aValue) == "abc"
    }
    
    func testMaybeWaitForValue_failureWithComplete() {
        mockHTTPClientRxy.doMaybeURLResult = .completed()
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForValue()?.aValue) == "abc"
    }
    
    func testMaybeWaitForError_failureWithValue() {
        mockHTTPClientRxy.doMaybeURLResult = .value(RemoteCallResponse(aValue: "abc"))
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
    func testMaybeWaitForError_failureWithComplete() {
        mockHTTPClientRxy.doMaybeURLResult = .completed()
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
}

