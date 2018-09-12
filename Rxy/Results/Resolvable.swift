
//  Copyright © 2018 Derek Clarkson. All rights reserved.

import RxSwift

/// Resolvables can be asked to resolve a result.
protocol Resolvable {
    associatedtype Sequence
    var resolve: () -> Sequence { get set }
}
