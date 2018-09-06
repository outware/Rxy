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
    
    func testLoadFromJSON() {
        
        let json =
        """
        {
        "value": "abc"
        }
        """
        
        let result = MaybeResult<Obj>.json(json).resolve().waitForValue()
        expect(result?.value) == "abc"
        
    }
    
}
