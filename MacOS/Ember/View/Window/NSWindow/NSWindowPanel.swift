// Copyright (c) 2021 Nomad5. All rights reserved.

import Cocoa
import MetalKit

class NSWindowPanel: Window {

    /// The window
    let window:    NSWindow

    /// The main view
    let metalView: MTKView

    /// Create the window
    init(at rect: CGRect) {
        window = NSWindow(contentRect: rect,
                          styleMask: [.nonactivatingPanel, .borderless],
                          backing: .buffered,
                          defer: true)

        window.level = .statusBar // .mainMenu
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        metalView = MTKView(frame: CGRect(origin: .zero, size: rect.size))
        window.contentView = metalView
        window.orderFrontRegardless()
    }

    func show() {
        Log.i("Showing window")
    }
}