// Copyright (c) 2021 Nomad5. All rights reserved.

import Cocoa
import MetalKit

class NSWindowPanel: Window {

    /// The window
    let window:     NSWindow

    /// The main view
    let renderView: RenderView

    /// Create the window
    init(renderView: RenderView, at rect: CGRect) {
        self.renderView = renderView
        window = NSWindow(contentRect: rect,
                          styleMask: [.nonactivatingPanel, .borderless],
                          backing: .buffered,
                          defer: true)

        window.level = .statusBar // .mainMenu
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = renderView
        window.orderFrontRegardless()
    }

    func show(image: CIImage) {
        renderView.setImage(image)
    }
}
