// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa
import SwiftUI

/// The main application model
class App {

    private let capture:       CaptureService
    private let assembler:     Assembler
    private let settingsView:  SettingsView
    private let windowFactory: WindowFactory

    /// Construction with dependencies
    init(with assembler: Assembler) {
        self.assembler = assembler
        self.settingsView = assembler.resolve()
        self.windowFactory = assembler.resolve()
        capture = assembler.resolve()
    }

    func start() {
        settingsView.show()
        capture.start()

        windowFactory.createWindow(at: .left).show()
        windowFactory.createWindow(at: .right).show()
    }

    func stop() {
    }
}