// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI

class SwiftUISettingsView: SettingsView {

    /// The window for the settings view
    private let window:            NSWindow

    // The SwiftUI view that provides the window contents.
    private let contentView:       SwiftUISettingsContentView

    private var cancelBag = CancelBag()

    /// Construction with dependencies
    init(imageProcessor: Processor, // TODO i dont like this dependency
         settings: Settings,
         actions: Actions) {
        let metalRenderView = MetalRenderView(frame: .zero,
                                              offset: 0,
                                              settings: settings,
                                              resize: true,
                                              fixNegativeExtent: true)
        self.contentView = SwiftUISettingsContentView(metalRenderView: metalRenderView)
        cancelBag.collect {
            imageProcessor.imageStream.sink { (image: CIImage) -> () in
                metalRenderView.setImage(image)
            }
        }
        // Create the window and set the content view.
        window = NSWindow(
                contentRect: CGRect(origin: .zero, size: CGSize(width: 400, height: 400)),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Settings Window")
        window.contentView = NSHostingView(
                rootView: contentView
                        .environmentObject(settings)
                        .environmentObject(actions))
        window.orderFrontRegardless()
    }

    /// Show the settings window
    func show() {
        window.makeKeyAndOrderFront(nil)
    }
}
