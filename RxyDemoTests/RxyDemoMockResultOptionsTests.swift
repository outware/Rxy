
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Rxy
import Nimble

// These tests show all the available mock result options.

class RxyDemoMockResultOptionsTests: XCTestCase {
    
    private var remoteService: RemoteService!
    private var mockHTTPClientRxy: MockHTTPClientRxy!
    
    override func setUp() {
        super.setUp()
        mockHTTPClientRxy = MockHTTPClientRxy()
        remoteService = RemoteService(client: mockHTTPClientRxy)
    }
    
    // MARK; - Completables
    
    func testCompletableCompleted() {
        mockHTTPClientRxy.postCompletableURLResult = .completed()
        self.remoteService.makeCompletableRemoteCall(toUrl: "xyz").waitForCompletion()
    }
    
    func testCompletableThrow() {
        mockHTTPClientRxy.postCompletableURLResult = .throw(TestError.anError)
        expect(self.remoteService.makeCompletableRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
    // MARK: - Singles
    
    func testSingleValue() {
        mockHTTPClientRxy.getSingleURLResult = .value(RemoteCallResponse(aValue: "abc"))
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
    }
    
    func testSingleClosure() {
        mockHTTPClientRxy.getSingleURLResult = .value { return RemoteCallResponse(aValue: "abc") }
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
    }
    
    func testSingleJSON() {
        let json =
        """
        {
            "aValue": "abc"
        }
        """
        mockHTTPClientRxy.getSingleURLResult = .json(json)
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
    }

    func testSingleJSONFromFile() {
        mockHTTPClientRxy.getSingleURLResult = .json(fromFile:"RemoteCallResult", inBundleWithClass: type(of:self))
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForSuccess()?.aValue) == "abc"
    }

    func testSingleError() {
        mockHTTPClientRxy.getSingleURLResult = .throw(TestError.anError)
        expect(self.remoteService.makeSingleRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
    // MARK: - Maybes
    
    func testMaybeValue() {
        mockHTTPClientRxy.doMaybeURLResult = .value(RemoteCallResponse(aValue: "abc"))
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForValue()?.aValue) == "abc"
    }

    func testMaybeClosure() {
        mockHTTPClientRxy.doMaybeURLResult = .value { return RemoteCallResponse(aValue: "abc") }
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForValue()?.aValue) == "abc"
    }

    func testMaybeJSON() {
        let json =
        """
        {
            "aValue": "abc"
        }
        """
        mockHTTPClientRxy.doMaybeURLResult = .json(json)
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForValue()?.aValue) == "abc"
    }
    
    func testMaybeJSONFromFile() {
        mockHTTPClientRxy.doMaybeURLResult = .json(fromFile:"RemoteCallResult", inBundleWithClass: type(of:self))
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForValue()?.aValue) == "abc"
    }
    
    func testMaybeError() {
        mockHTTPClientRxy.doMaybeURLResult = .throw(TestError.anError)
        expect(self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForError()).to(matchError(TestError.anError))
    }
    
    func testMaybeCompleted() {
        mockHTTPClientRxy.doMaybeURLResult = .completed()
        self.remoteService.makeMaybeRemoteCall(toUrl: "xyz").waitForCompletion()
    }
    
}

