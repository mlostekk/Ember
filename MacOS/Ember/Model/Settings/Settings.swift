// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine

class Settings: Service, ObservableObject {

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: Settings.self)

    /// This is the main publisher for the blur
    @Published var blurAmount: Double = 10.0

    /// This is the main publisher for the frame rate
    @Published var frameRate:  Double = 30

}
