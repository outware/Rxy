
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

public class Result<T, O>: Resolvable {
    
    var eventFactory: (AnyObserver<T>) -> Void
    
    required init(factory: @escaping (AnyObserver<T>) -> Void) {
        self.eventFactory = factory
    }
    
    var resolveObservable: Observable<T> {
        return Observable<T>.create { observable in
            self.eventFactory(observable)
            return Disposables.create()
        }
    }
    
    var resolved: O {
        fatalError()
    }
}

public extension Result where T: Decodable {
    
    public static func json(_ json: String) -> Self {
        return loadJSON(getDataClosure: { json.data(using: .utf8) }, noDataError: RxyError.invalidData, sourceJSON: json)
    }
    
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
