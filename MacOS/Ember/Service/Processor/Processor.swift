// Copyright (c) 2021 Nomad5. All rights reserved.

import Combine
import CoreImage

typealias ImageStream = AnyPublisher<CIImage, Never>

protocol Processor {
    /// Process the source image
    func process(image: CIImage)

    /// The result image steam for the full processed image
    var imageStreamFull:  ImageStream { get }
    /// The result image steam for the left processed image
    var imageStreamLeft:  ImageStream { get }
    /// The result image steam for the right processed image
    var imageStreamRight: ImageStream { get }
}
