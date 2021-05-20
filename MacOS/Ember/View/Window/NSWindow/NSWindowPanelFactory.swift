// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

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

    func createWindowAt(position: WindowPosition,
                        sourceAspectRatio: AspectRatio,
                        targetScreen: NSScreen) -> Window {
        let placement  = placementProvider.getPlacement(for: position,
                                                        sourceAspectRatio: sourceAspectRatio,
                                                        targetScreen: targetScreen)
        let renderView = renderViewFactory.createRenderView(at: placement)
        return NSWindowPanel(renderView: renderView, at: placement.target)
    }
}
