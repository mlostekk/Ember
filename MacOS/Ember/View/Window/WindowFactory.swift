// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

enum WindowPosition {
    case left
    case right

    var placementType: PlacementType {
        switch self {
            case .left:
                return .left
            case .right:
                return .right
        }
    }
}

/// Abstract factory
protocol WindowFactory {

    func createWindow(at position: WindowPosition) -> Window
}
