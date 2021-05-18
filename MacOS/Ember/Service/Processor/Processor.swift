// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import CoreImage
import Combine

protocol Processor {
    /// Publish a source image
    func publish(image: CIImage)

    /// The result image
    var imageStream: AnyPublisher<CIImage, Never> { get }
}

class SimpleImageProcessor: Service, Processor {

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: SimpleImageProcessor.self)

    /// The internal subject
    private let imageSubject  = PassthroughSubject<CIImage, Never>()

    /// Effects
    private let contrastBoost = CIFilter(name: "CIColorControls")!

    /// Injected dependencies
    private let settings: Settings

    /// The image stream exposed to consumers
    var imageStream: AnyPublisher<CIImage, Never> {
        imageSubject.eraseToAnyPublisher()
    }

    /// Construction
    init(settings: Settings) {
        self.settings = settings
    }

    /// Publish a source image
    func publish(image: CIImage) {
        contrastBoost.setValue(image, forKey: kCIInputImageKey)
        contrastBoost.setValue(1.0, forKey: "inputContrast")
        let contrastImage = contrastBoost.outputImage!
        let blurred       = contrastImage.applyingGaussianBlur(sigma: settings.blurAmount)
        imageSubject.send(blurred)
    }

}