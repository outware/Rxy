
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MaybeResultTests: XCTestCase {

    func testError() {
        expect(MaybeResult<Int>.throw(TestError.anError).resolved.waitForError()).to(matchError(TestError.anError))
    }

    func testValue() {
        expect(MaybeResult<Int>.value(5).resolved.waitForValue()) == 5
    }

    func testValueClosure() {
        expect(MaybeResult<Int>.value { return 5 }.resolved.waitForValue()) == 5
    }

    func testWithOptionalValue() {
        expect(MaybeResult<Int?>.value(nil).resolved.waitForValue()!).to(beNil())
    }

    func testSuccess() {
        MaybeResult<Int>.completed().resolved.waitForCompletion()
    }
    
    // MARK: - JSON
    
    func testJSON() {
        let result = MaybeResult<Obj>.json(json).resolved.waitForValue()
        expect(result?.value) == "abc"
    }

    func testJSONIncorrectType() {
        expectNimble(error: "Expected a value, got error RxyError.decodingError(expected: RxyTests.OtherObj",
                     usingMatcher: { $0.hasPrefix($1) }) {
                        MaybeResult<OtherObj>.json(json).resolved.waitForValue()
        }
    }

    func testJSONFile() {
        let result = MaybeResult<Obj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolved.waitForValue()
        expect(result?.value) == "abc"
    }

    func testJSONFileIncorrectType() {
        expectNimble(error: "Expected a value, got error RxyError.decodingError(expected: RxyTests.OtherObj",
                     usingMatcher: { $0.hasPrefix($1) }) {
                        MaybeResult<OtherObj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolved.waitForValue()
        }
    }

    func testJSONFileFileNotFound() {
        expectNimble(error: "Expected a value, got error RxyError.fileNotFound instead") {
            MaybeResult<Obj>.json(fromFile: "xxx", inBundleWithClass: type(of: self)).resolved.waitForValue()
        }
    }
}
