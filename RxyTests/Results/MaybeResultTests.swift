
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
import Nimble
@testable import Rxy

class MaybeResultTests: XCTestCase {

    func testError() {
        expect(MaybeResult<Int>.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }

    func testValue() {
        expect(MaybeResult<Int>.value(5).resolve().waitForValue()) == 5
    }

    func testValueClosure() {
        expect(MaybeResult<Int>.value { return 5 }.resolve().waitForValue()) == 5
    }

    func testWithOptionalValue() {
        expect(MaybeResult<Int?>.value(nil).resolve().waitForValue()!).to(beNil())
    }

    func testSuccess() {
        MaybeResult<Int>.completed().resolve().waitForCompletion()
    }
    
    // MARK: - JSON
    
    func testJSON() {
        let result = MaybeResult<Obj>.json(json).resolve().waitForValue()
        expect(result?.value) == "abc"
    }

    func testJSONIncorrectType() {
        expectNimble(error: "Expected a value, got error RxyError.decodingError(expected: RxyTests.OtherObj",
                     usingMatcher: { $0.hasPrefix($1) }) {
                        MaybeResult<OtherObj>.json(json).resolve().waitForValue()
        }
    }

    func testJSONFile() {
        let result = MaybeResult<Obj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolve().waitForValue()
        expect(result?.value) == "abc"
    }

    func testJSONFileIncorrectType() {
        expectNimble(error: "Expected a value, got error RxyError.decodingError(expected: RxyTests.OtherObj",
                     usingMatcher: { $0.hasPrefix($1) }) {
                        MaybeResult<OtherObj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolve().waitForValue()
        }
    }

    func testJSONFileFileNotFound() {
        expectNimble(error: "Expected a value, got error RxyError.fileNotFound instead") {
            MaybeResult<Obj>.json(fromFile: "xxx", inBundleWithClass: type(of: self)).resolve().waitForValue()
        }
    }
}
