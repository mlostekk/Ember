// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI
import Combine

/// The main application model
class App {

    /// The subscription
    private var captureSubscription:   AnyCancellable!
    private var processorSubscription: AnyCancellable!

    /// Dependencies
    private let capture:               CaptureService
    private let imageProcessor:        Processor
    private let assembler:             Assembler
    private let settingsView:          SettingsView
    private let windowFactory:         WindowFactory
    private var windows:               [WindowPosition: Window] = [:]

    /// Construction with dependencies
    init(with assembler: Assembler) {
        self.assembler = assembler
        self.settingsView = assembler.resolve()
        self.windowFactory = assembler.resolve()
        self.imageProcessor = assembler.resolve()
        capture = assembler.resolve()
    }

    func start() {
        /// Settings
        settingsView.show()

        /// Rendering windows
        windows[.left] = windowFactory.createWindow(at: .left)
        windows[.right] = windowFactory.createWindow(at: .right)

        /// Handling the processed image
        processorSubscription = imageProcessor.imageStream.sink { [weak self] ciImage in
            self?.windows.forEach { _, window in
                window.show(image: ciImage)
            }
        }

        /// Configure image rendering
        /// Configure capturing
        captureSubscription = capture.pixelBuffer.sink { [weak self] ciImage in
            self?.imageProcessor.publish(image: ciImage)
        }
        capture.start()

    }

    func stop() {
    }
}