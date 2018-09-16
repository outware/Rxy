
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

extension Bundle {

    /**
     Loads and returns the contents of a file stored in a bundle.
     
     - Parameter filename: The name of the file to load. Can either be the file name if extension is provided or filename.extension. Either will work.
     - Parameter extension: The extension of the file. If not passed then it will be assumed that the filename argument contains both the filename and extension.
     - Parameter fromBundleWithClass: A class that identifies the bundle to search for the file.
     - Returns: The contents of the file or nil if the file does not exist in the bundle or there is some other loading error.
     */
    static func contentsOfFile(_ filename: String, extension ext:String? = nil, fromBundleWithClass aClass: AnyClass) -> Data? {
        let bundle = Bundle(for: aClass)
        if let url = bundle.url(forResource: filename, withExtension: ext) ?? bundle.url(forResource: filename, withExtension: nil) {
            return try? Data(contentsOf: url)
        }
        return nil
    }
}
