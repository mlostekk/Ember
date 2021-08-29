// Copyright (c) 2021 Nomad5. All rights reserved.

import Cocoa
import MetalKit

class NSWindowPanel: Window {

    /// The window
    private let window:     NSWindow

    /// Injections
    private let renderView: RenderView
    private let actions:    Actions

    /// Create the window
    init(renderView: RenderView,
         at rect: CGRect,
         actions: Actions) {
        self.renderView = renderView
        self.actions = actions
        window = NSWindow(contentRect: rect,
                          styleMask: [.nonactivatingPanel, .borderless],
                          backing: .buffered,
                          defer: true)

        window.level = .statusBar // .mainMenu
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = renderView
        window.orderFrontRegardless()
        window.isReleasedWhenClosed = false
        // configure triple click
        let tripleClick = NSClickGestureRecognizer(target: self, action: #selector(handleTripleClick))
        tripleClick.numberOfClicksRequired = 3
        window.contentView?.addGestureRecognizer(tripleClick)
    }

    /// Handle triple click
    @objc func handleTripleClick() {
        Log.i("Triple click executed")
        actions.openSettingsWindow.send(())
    }

    /// Destruction
    deinit {
        Log.d("Window destroyed")
    }

    /// Pass down the image
    func show(image: CIImage) {
        renderView.setImage(image)
    }

    /// Close the window
    func close() {
        window.close()
    }
}
