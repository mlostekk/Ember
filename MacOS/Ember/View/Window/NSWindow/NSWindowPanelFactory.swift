// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

class NSWindowPanelFactory: WindowFactory {

    /// Injected dependencies
    private let placementProvider: PlacementProvider
    private let renderViewFactory: RenderViewFactory

    /// Construction with dependencies
    init(placementProvider: PlacementProvider,
         renderViewFactory: RenderViewFactory) {
        self.placementProvider = placementProvider
        self.renderViewFactory = renderViewFactory
    }

    func createWindow(at position: WindowPosition) -> Window {
        NSWindowPanel(renderView: renderViewFactory.createRenderView(at: position),
                      at: placementProvider.getPlacement(for: position.placementType).target)
    }
}