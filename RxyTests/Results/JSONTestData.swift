
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import Foundation

class Obj: Decodable {
    let value: String
}

class OtherObj: Decodable {
    let number: Int
}

public let json =
"""
{
"value": "abc"
}
"""
