
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// The abstract parent of Result classes.
public class Result<EventType> {

    typealias EventClosure = (EventType) -> Void

    var eventFactory: (@escaping EventClosure) -> Void

    required init(factory: @escaping (@escaping EventClosure) -> Void) {
        self.eventFactory = factory
    }

    func resolve(_ event: @escaping EventClosure) -> Disposable {
        self.eventFactory(event)
        return Disposables.create()
    }

    static func loadJSON<ValueType>(
        successClosure: @escaping (@escaping EventClosure, ValueType) -> Void,
        errorClosure: @escaping (@escaping EventClosure, Error) -> Void,
        getDataClosure : @escaping () -> Data?,
        noDataError: Error,
        sourceJSON: String? = nil) -> Self where ValueType: Decodable {

        return self.init { single in
            do {
                guard let data = getDataClosure() else {
                    errorClosure(single, noDataError)
                    return
                }

                let decoder = JSONDecoder.init()
                let obj = try decoder.decode(ValueType.self, from: data)
                successClosure(single, obj)
            }
            catch let error {
                errorClosure(single, RxyError.decodingError(expected: ValueType.self, fromJSON: sourceJSON, error: error))
            }
        }
    }
}
