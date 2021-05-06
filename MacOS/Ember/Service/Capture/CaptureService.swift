// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import CoreMedia
import Combine

protocol CaptureService {

    /// The captured pixel buffer
    var pixelBuffer: AnyPublisher<CMSampleBuffer, Never> { get }

    /// Start capturing
    func start()

    /// Stop capturing
    func stop()
}