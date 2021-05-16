// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine

class Settings: Service, ObservableObject {

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: Settings.self)

    /// This is the main publisher for the settings
    @Published var blurAmount: Double = 10.0 {
        willSet {
            print(newValue)
        }
    }

}
