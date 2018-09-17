//
//  JSONTests.swift
//  RxyTests
//
//  Created by Derek Clarkson on 6/9/18.
//  Copyright © 2018 Derek Clarkson. All rights reserved.
//

import XCTest
import Nimble
@testable import Rxy
import RxSwift

class SingleResultTests: XCTestCase {
    
    func testError() {
        expect(SingleResult<Int>.throw(TestError.anError).resolve().waitForError()).to(matchError(TestError.anError))
    }
    
    func testValue() {
        expect(SingleResult<Int>.value(5).resolve().waitForSuccess()) == 5
    }
    
    func testValueClosure() {
        expect(SingleResult<Int>.value { return 5 }.resolve().waitForSuccess()) == 5
    }
    
    func testWithOptionalValue() {
        expect(SingleResult<Int?>.value(nil).resolve().waitForSuccess()!).to(beNil())
    }
    
    // MARK: - JSON
    
    func testJSON() {
        let result = SingleResult<Obj>.json(json).resolve().waitForSuccess()
        expect(result?.value) == "abc"
    }
    
    func testJSONIncorrectType() {
        expectNimble(error: "Expected a single value, got error RxyError.decodingError(expected: RxyTests.OtherObj",
                     usingMatcher: { $0.hasPrefix($1) }) {
                        SingleResult<OtherObj>.json(json).resolve().waitForSuccess()
        }
    }
    
    func testJSONFile() {
        let result = SingleResult<Obj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolve().waitForSuccess()
        expect(result?.value) == "abc"
    }
    
    func testJSONFileIncorrectType() {
        expectNimble(error: "Expected a single value, got error RxyError.decodingError(expected: RxyTests.OtherObj",
                     usingMatcher: { $0.hasPrefix($1) }) {
                        SingleResult<OtherObj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolve().waitForSuccess()
        }
    }
    
    func testJSONFileFileNotFound() {
        expectNimble(error: "Expected a single value, got error RxyError.fileNotFound instead") {
            SingleResult<Obj>.json(fromFile: "xxx", inBundleWithClass: type(of: self)).resolve().waitForSuccess()
        }
    }
}
