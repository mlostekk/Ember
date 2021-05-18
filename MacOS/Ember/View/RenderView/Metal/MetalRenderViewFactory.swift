// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class MetalRenderViewFactory: RenderViewFactory {

    /// Injected dependencies
    private let placementProvider: PlacementProvider

    /// Construction with dependencies
    init(placementProvider: PlacementProvider) {
        self.placementProvider = placementProvider
    }

    func createRenderView(at position: WindowPosition) -> RenderView {
        let placement = placementProvider.getPlacement(for: position.placementType)
        return MetalRenderView(frame: placement.target, offset: placement.offset)
    }
}
