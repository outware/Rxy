
//  Copyright © 2018 Derek Clarkson. All rights reserved.

/**
 Defines JSON results for Decodable instances.
 */
public protocol JSONFactory {
    
    init(json: String)

    init(jsonFromFile fromFile: String, extension ext: String?, inBundleWithClass aClass: AnyClass)

    /**
     Source a result from JSON in a passed string.
     
     - Parameter json: A String containing valid JSON.
     - Returns: an instance of the Result.
     */
    static func json(_ json: String) -> Self
    
    /**
     Loads a json response from a file.
     
     - Parameter fromFile: the name of a file to load the json from. Can include or exclude a file extension.
     - Parameter extension: The file extension. Defaults to "json". Not required unless it's different to "json"
     and the fromFile argument doesn't include the extension. Specifying nil means the filename contains the extension
     or there is no extension (Not recommended).
     - Parameter inBundleWithClass: A class that is in the same bundle where the file is stored.
     - Returns: an instance of the Result.
     */
    static func json(fromFile: String, extension ext: String?, inBundleWithClass: AnyClass) -> Self
}

/// Factory method for all value factory instances.
public extension JSONFactory where Self: ValueFactory, Self.Element: Decodable {
    
    public static func json(_ json: String) -> Self {
        return self.init(json: json)
    }

    public static func json(fromFile: String, extension ext: String? = "json", inBundleWithClass: AnyClass) -> Self {
        return self.init(jsonFromFile: fromFile, extension: ext, inBundleWithClass: inBundleWithClass)
    }
}
