
//  Copyright © 2018 Derek Clarkson. All rights reserved.

/**
 Defines JSON results for Decodable instances.
 */
public protocol JSONFactory {

    init(json: String)
    /**
     Source a result from JSON in a passed string.

     - Parameter json: A String containing valid JSON.
     - Returns: an instance of the Result.
     */
    static func json(_ json: String) -> Self
}

/// Factory method for all value factory instances.
public extension JSONFactory where Self: ValueFactory, Self.Element: Decodable {

    public static func json(_ json: String) -> Self {
        return self.init(json: json)
    }
}

/// Extensions giving access to the json initializers.

extension SingleResult: JSONFactory where T: Decodable {

    public convenience init(json: String) {
        self.init(resolver: SingleResolver<T>(json: json))
    }
}

extension MaybeResult: JSONFactory where T: Decodable {

    public convenience init(json: String) {
        self.init()
        self.resolve = MaybeResolver<T>(json: json).resolve
    }
}

// MARK: - Resolver

extension ValueResolver where T: Decodable {

    convenience init(json: String) {

        self.init()
        self.valueClosure = {

            if let jsonData = json.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder.init()
                    return try decoder.decode(T.self, from: jsonData)
                }
                catch let error {
                    throw RxyError.decodingError(expected: T.self, fromJSON: json, error: error)
                }
            }

            throw RxyError.invalidJSON
        }
    }
}

