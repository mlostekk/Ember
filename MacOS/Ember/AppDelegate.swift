// Copyright (c) 2021 Nomad5. All rights reserved.

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    /// The main DI container
    private let assembler: Assembler = AppAssembler()
    private lazy var app: App = {
        App(with: assembler)
    }()

    /// Console logging
    private let consoleLog = OSConsoleLog(with: Log.logEntryPublisher)

    /// Application start
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        app.start()
    }

    /// User clicked on the icon in the dock
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        app.openSettingsView()
        return true
    }

    /// Application end
    func applicationWillTerminate(_ aNotification: Notification) {
        app.stop()
    }

    /// Restore main window
    @IBAction func onMenuRestoreMainWindow(_ sender: Any) {
        app.openSettingsView()
    }
}

