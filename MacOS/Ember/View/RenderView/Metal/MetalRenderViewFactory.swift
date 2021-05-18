// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class MetalRenderViewFactory: RenderViewFactory {

    /// Injected dependencies
    private let placementProvider: PlacementProvider
    private let settings:          Settings

    /// Construction with dependencies
    init(placementProvider: PlacementProvider, settings: Settings) {
        self.placementProvider = placementProvider
        self.settings = settings
    }

    func createRenderView(at position: WindowPosition) -> RenderView {
        let placement = placementProvider.getPlacement(for: position.placementType)
        return MetalRenderView(frame: placement.target,
                               offset: placement.offset,
                               settings: settings)
    }
}
