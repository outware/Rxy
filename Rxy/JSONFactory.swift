
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

/// Extensions giving access to the json initializers.

extension SingleResult: JSONFactory where T: Decodable {
    
    public convenience init(json: String) {
        self.init(resolver: SingleResolver<T>(json: json))
    }
    
    public convenience init(jsonFromFile fromFile: String, extension ext: String?, inBundleWithClass aClass: AnyClass) {
        self.init(resolver: SingleResolver<T>(jsonFileName: fromFile, extension: ext, inBundleWithClass: aClass))
    }
}

extension MaybeResult: JSONFactory where T: Decodable {
    
    public convenience init(json: String) {
        self.init(resolver: MaybeResolver<T>(json: json))
    }
    
    public convenience init(jsonFromFile fromFile: String, extension ext: String?, inBundleWithClass aClass: AnyClass) {
        self.init(resolver: MaybeResolver<T>(jsonFileName: fromFile, extension: ext, inBundleWithClass: aClass))
    }
}

// MARK: - Resolver

extension ValueResolver where T: Decodable {
    
    convenience init(json: String) {
        self.init()
        self.valueClosure = {
            guard let data = json.data(using: .utf8) else {
                throw RxyError.invalidData
            }
            return try self.loadJSON(data, source: json)
        }
    }
    
    convenience init(jsonFileName filename: String, extension ext: String?, inBundleWithClass aClass: AnyClass) {
        self.init()
        self.valueClosure = {
            guard let jsonData = try Bundle.contentsOfFile(filename, extension: ext, fromBundleWithClass: aClass) else {
                throw RxyError.fileNotFound
            }
            return try self.loadJSON(jsonData)
        }
    }
    
    private func loadJSON(_ data: Data, source json: String? = nil) throws -> T {
        do {
            let decoder = JSONDecoder.init()
            return try decoder.decode(T.self, from: data)
        }
        catch let error {
            throw RxyError.decodingError(expected: T.self, fromJSON: json, error: error)
        }
    }
}

