// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol SettingsView {

    /// Show the settings view
    func show()

    /// Attach an image stream for preview
    func attach(imageStream: ImageStream)
}
