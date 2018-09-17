
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Resolvables can be asked to produce a result.
protocol Resolvable {
    associatedtype Sequence
    func resolve() -> Sequence
}

