
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

public class Result<T> {
    
    var eventFactory: (AnyObserver<T>) -> Void
    
    required init(factory: @escaping (AnyObserver<T>) -> Void) {
        self.eventFactory = factory
    }
    
    func resolveObservable() -> Observable<T> {
        return Observable<T>.create { observable in
            self.eventFactory(observable)
            return Disposables.create()
        }
    }
}

/// Extension which can load data when the type being returned is a Decodable.
public extension Result where T: Decodable {

    /**
     Creates the desired instances from a passed string containing JSON.
     
     - Parameter json: A string containing JSON that will be loaded into an instance of the returned type.
    */
    public static func json(_ json: String) -> Self {
        return loadJSON(getDataClosure: { json.data(using: .utf8) }, noDataError: RxyError.invalidData, sourceJSON: json)
    }

    /**
     Creates the desired instance from the contents of a file.
     
     It is assumed that the file contains JSON.
     
     - Parameter fromFile: The file that contains the JSON. This file must be in a bundle. The name can include an extension or use
     the default of '.json'.
     - Parameter extension: The extension of the file to search for. The default for this is '.json'.
     - Parameter inBundleWithClass: When the file is located in a different bundle, pass a class to this argument to locate the relevant bundle.
     */
    public static func json(fromFile: String, extension ext: String? = "json", inBundleWithClass aClass: AnyClass) -> Self {
        return loadJSON(
            getDataClosure: { Bundle.contentsOfFile(fromFile, extension: ext, fromBundleWithClass: aClass) },
            noDataError: RxyError.fileNotFound
        )
    }

    static func loadJSON(
        getDataClosure : @escaping () -> Data?,
        noDataError: Error,
        sourceJSON: String? = nil) -> Self {
        
        return self.init { observable in
            do {
                guard let data = getDataClosure() else {
                    observable.on(.error(noDataError))
                    return
                }
                
                let decoder = JSONDecoder.init()
                let obj = try decoder.decode(T.self, from: data)
                
                observable.on(.next(obj))
                observable.on(.completed)
            }
            catch let error {
                observable.on(.error(RxyError.decodingError(expected: T.self, fromJSON: sourceJSON, error: error)))
            }
        }
    }
}
