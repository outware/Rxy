
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import XCTest
@testable import Rxy
import Nimble

class Bundle_ExtensionsTests: XCTestCase {

    func testContentsOfFileLoadsFile() throws {
        let fileData = Bundle.contentsOfFile("abc", extension: "json", fromBundleWithClass: type(of:self))
        expect(fileData).toNot(beNil())
    }

    func testContentsOfFileLoadsFileWithExtension() throws {
        let fileData = Bundle.contentsOfFile("abc.json", extension: "json", fromBundleWithClass: type(of:self))
        expect(fileData).toNot(beNil())
    }

    func testContentsOfFileLoadsFileWithoutExtension() throws {
        let fileData = Bundle.contentsOfFile("abc.json", fromBundleWithClass: type(of:self))
        expect(fileData).toNot(beNil())
    }

    func testContentsOfFileFailsToFindFile() throws {
        let fileData = Bundle.contentsOfFile("abc.x", fromBundleWithClass: type(of:self))
        expect(fileData).to(beNil())
    }
}
