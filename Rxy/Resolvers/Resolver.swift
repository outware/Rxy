
//  Created by Derek Clarkson on 30/8/18.

import RxSwift

/// Resolvers can resolve a result of a mocked call.
protocol Resolver {
    associatedtype Sequence
    func resolve() -> Sequence
}

/**
 Resolvers provide the implementations for produce results for mocked calls.
 */

/// Base resolver for all resolves. Can produce an error result or a void result.
class BaseResolver {
    
    let error: Error?
    
    init() {
        error = nil
    }
    
    init(error: Error) {
        self.error = error
    }
}

/// Base resolver for resolvers that can produce values.
class ValueResolver<T>: BaseResolver {
    
    var valueClosure: (() throws -> T)?
    
    // MARK Lifecycle
    
    convenience init(value: @escaping () throws -> T) {
        self.init()
        self.valueClosure = value
    }
    
    /// Shared core logic for processing values.
    func resolveValue<O>(success: (T) -> O, failure: (Error) -> O) -> O? {
        
        // If there is a value closure then return it or fail with any error thrown by it.
        if let valueClosure = valueClosure {
            do {
                return success(try valueClosure())
            }
            catch let error {
                return failure(error)
            }
        }

        // If there is an error then return it.
        if let error = self.error {
            return failure(error)
        }

        // Otherwise return a nil.
        return nil
    }
}

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
