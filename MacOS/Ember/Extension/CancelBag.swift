// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine

/// The convenience type mapping
typealias CancelBag = Set<AnyCancellable>

extension CancelBag {
    mutating func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
        formUnion(cancellables())
    }

    @_functionBuilder
    struct Builder {
        static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
            return cancellables
        }
    }
}