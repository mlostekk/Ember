// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI
import Combine

/// The main application model
class App {

    /// Dependencies
    private let capture:        CaptureService
    private let imageProcessor: Processor
    private let assembler:      Assembler
    private let settingsView:   SettingsView
    private let windowFactory:  WindowFactory
    private let settings:       Settings
    private let actions:        Actions
    private var windows:        [WindowPosition: Window] = [:]

    /// The cancel bag
    private var globalCancelBag                          = CancelBag()
    private var windowCancelBag                          = CancelBag()

    /// Construction with dependencies
    init(with assembler: Assembler) {
        self.assembler = assembler
        self.settingsView = assembler.resolve()
        self.windowFactory = assembler.resolve()
        self.imageProcessor = assembler.resolve()
        self.settings = assembler.resolve()
        self.actions = assembler.resolve()
        capture = assembler.resolve()
    }

    func start() {
        /// Settings
        settingsView.show()
        globalCancelBag.collect {
            /// Subscribe to start button
            actions.startRenderingStream.sink { [weak self] in
                guard let self = self else { return }
                self.showWindows(sourceAspectRatio: self.settings.sourceAspectRatio, targetScreen: self.settings.selectedScreen)
            }
            /// Subscribe to stop button
            actions.stopRenderingStream.sink { [weak self] in
                guard let self = self else { return }
                self.killWindows()
            }
        }
    }

    private func showWindows(sourceAspectRatio: AspectRatio, targetScreen: NSScreen) {
        /// Rendering windows
        windows[.left] = windowFactory.createWindowAt(position: .left, sourceAspectRatio: sourceAspectRatio, targetScreen: targetScreen)
        windows[.right] = windowFactory.createWindowAt(position: .right, sourceAspectRatio: sourceAspectRatio, targetScreen: targetScreen)

        windowCancelBag.collect {
            /// Handling the processed image
            imageProcessor.imageStream.sink { [weak self] ciImage in
                self?.windows.forEach { _, window in
                    window.show(image: ciImage)
                }
            }
            /// Configure capturing & rendering
            capture.pixelBuffer.sink { [weak self] ciImage in
                self?.imageProcessor.publish(image: ciImage)
            }
        }
        capture.start()
    }

    private func killWindows() {
        windowCancelBag.removeAll()
        windows.forEach { $1.close() }
        windows.removeAll()
    }

    func stop() {
    }
}