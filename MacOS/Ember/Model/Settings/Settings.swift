// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import Cocoa

class Settings: Service, ObservableObject {

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: Settings.self)

    @Published var blurAmount:     Double   = 10.0
    @Published var frameRate:      Double   = 30
    @Published var selectedScreen: NSScreen = NSScreen.main!

}
