// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI

class SwiftUISettingsView: SettingsView {

    /// The window for the settings view
    private let window:          NSWindow

    // The SwiftUI view that provides the window contents.
    private let contentView:     SwiftUISettingsContentView

    /// The metal render view for the image preview
    private let metalRenderView: MetalRenderView

    /// Combine cancellation bag
    private var cancelBag = CancelBag()


    /// Construction with dependencies
    init(settings: Settings, actions: Actions) {
        metalRenderView = MetalRenderView(frame: .zero,
                                          settings: settings,
                                          resize: true)
        contentView = SwiftUISettingsContentView(metalRenderView: metalRenderView)

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

    /// Attach the image stream
    func attach(imageStream: ImageStream) {
        cancelBag.collect {
            imageStream.sink { [weak self] (image: CIImage) -> () in
                self?.metalRenderView.setImage(image)
            }
        }
    }
}
