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

class Obj: Decodable {
    let value: String
}

class OtherObj: Decodable {
    let number: Int
}

class JSONFactoryTests: XCTestCase {
    
    // MARK: - JSON from a string.
    
    let json =
    """
        {
        "value": "abc"
        }
        """
    
    func testLoadSingleFromJSON() {
        let result = SingleResult<Obj>.json(json).resolve().waitForSuccess()
        expect(result?.value) == "abc"
    }
    
    func testLoadMaybeFromJSON() {
        let result = MaybeResult<Obj>.json(json).resolve().waitForValue()
        expect(result?.value) == "abc"
    }
    
    func testLoadInvalidJSON() {
        expectNimble(error: "The given data was not valid JSON.", usingMatcher: { $0.contains($1) }) {
            SingleResult<Obj>.json("#😄␃").resolve().waitForSuccess()
        }
    }
    
    func testLoadWrongType() {
        expectNimble(error: "RxyError.decodingError", usingMatcher: { $0.contains($1) }) {
            SingleResult<OtherObj>.json(json).resolve().waitForSuccess()
        }
    }
    
    // MARK: - JSON from a file.
    
    func testLoadSingleFromAJSONFile() {
        let result = SingleResult<Obj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolve().waitForSuccess()
        expect(result?.value) == "abc"
    }
    
    func testLoadMaybeFromAJSONFile() {
        let result = MaybeResult<Obj>.json(fromFile: "abc", inBundleWithClass: type(of: self)).resolve().waitForValue()
        expect(result?.value) == "abc"
    }
    
    func testLoadSingleFromAJSONFileGeneratesFileNotFound() {
        expectNimble(error: "Expected a single value, got error RxyError.fileNotFound instead") {
            SingleResult<Obj>.json(fromFile: "xxx", inBundleWithClass: type(of: self)).resolve().waitForSuccess()
        }
    }

    func testLoadMaybeFromAJSONFileGeneratesFileNotFound() {
        expectNimble(error: "Expected a value, got error RxyError.fileNotFound instead") {
            MaybeResult<Obj>.json(fromFile: "xxx", inBundleWithClass: type(of: self)).resolve().waitForValue()
        }
    }

    func testLoadSingleFromInvalidDataFileGeneratesDecodingError() {
        expectNimble(error: "Expected a single value, got error RxyError.decodingError(", usingMatcher: { $0.contains($1) }) {
            SingleResult<Obj>.json(fromFile: "invalid", extension: "jpg", inBundleWithClass: type(of: self)).resolve().waitForSuccess()
        }
    }
}
