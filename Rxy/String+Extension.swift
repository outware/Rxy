
//  Copyright © 2018 Derek Clarkson. All rights reserved.

extension String {
    
    func filename(withFunction function:String? = nil) -> String {

        let filename = URL(fileURLWithPath: self).lastPathComponent.split(separator: ".").first

        if let filename = filename, let function = function {
            return "\(filename).\(function)"

        } else if let filename = filename {
            return String(filename)

        } else if let function = function {
            return function

        } else {
            return ""
        }
    }
}
