// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

extension CGSize {
    var asRect: CGRect {
        CGRect(origin: .zero, size: self)
    }
}