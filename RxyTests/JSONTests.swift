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

class JSONTests: XCTestCase {

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
            SingleResult<Obj>.json("abc").resolve().waitForSuccess()
        }
    }

}
