// Copyright (c) 2021 Nomad5. All rights reserved.

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    /// The main DI container
    let assembler: Assembler = AppAssembler()
    lazy var app: App = {
        App(with: assembler)
    }()

    /// Console logging
    let consoleLog = OSConsoleLog(with: Log.logEntryPublisher)

    /// Application start
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        app.start()
    }

    /// Application end
    func applicationWillTerminate(_ aNotification: Notification) {
        app.stop()
    }

}

