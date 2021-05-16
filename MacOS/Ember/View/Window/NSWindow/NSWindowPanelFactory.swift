// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class NSWindowPanelFactory: WindowFactory {

    /// Injected dependencies
    private let placementProvider: PlacementProvider

    /// Construction with dependencies
    init(placementProvider: PlacementProvider) {
        self.placementProvider = placementProvider
    }

    func createWindow(at position: WindowPosition) -> Window {
        NSWindowPanel(at: placementProvider.getPlacement(for: position.placementType).target)
    }
}