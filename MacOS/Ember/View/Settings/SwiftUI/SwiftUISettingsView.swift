// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI

class SwiftUISettingsView: SettingsView {

    /// Dependencies
    private let placementProvider: PlacementProvider

    // The SwiftUI view that provides the window contents.
    private let contentView = SwiftUISettingsContentView()

    /// The window for the settings view
    private let window:            NSWindow

    /// Construction with dependencies
    init(placementProvider: PlacementProvider) {
        self.placementProvider = placementProvider
        // Create the window and set the content view.
        window = NSWindow(
                contentRect: placementProvider.getPlacement(for: .settings).target,
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Settings Window")
        window.contentView = NSHostingView(rootView: contentView)
    }

    /// Show the settings window
    func show() {
        window.makeKeyAndOrderFront(nil)
    }
}
