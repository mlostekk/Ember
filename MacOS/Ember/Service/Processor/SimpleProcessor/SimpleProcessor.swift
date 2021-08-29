// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import CoreImage
import Combine

/// Image processing queue
/// Inspirations taken from:
///     https://willowtreeapps.com/ideas/how-to-apply-a-filter-to-a-video-stream-in-ios
class SimpleProcessor: Service, Processor {

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: SimpleProcessor.self)

    /// The internal subject
    private let imageSubjectFull  = PassthroughSubject<CIImage, Never>()
    private let imageSubjectLeft  = PassthroughSubject<CIImage, Never>()
    private let imageSubjectRight = PassthroughSubject<CIImage, Never>()

    /// The image stream exposed to consumers
    var imageStreamFull:  ImageStream {
        imageSubjectFull.eraseToAnyPublisher()
    }
    var imageStreamRight: ImageStream {
        imageSubjectRight.eraseToAnyPublisher()
    }
    var imageStreamLeft:  ImageStream {
        imageSubjectLeft.eraseToAnyPublisher()
    }

    /// Additional static offset to bar width to avoid red borders
    private let staticBarWidthOffset: CGFloat = 1

    /// Injected dependencies
    private let settings:             Settings
    private let barWidth:             CGFloat

    /// Construction
    init(settings: Settings, barWidth: CGFloat) {
        self.settings = settings
        self.barWidth = barWidth
    }

    /// Publish a source image
    func process(image: CIImage) {
        // 0. VARS
        let scale         = CGFloat(settings.scale)
        let blur          = settings.blurAmount
        let barWidth      = (barWidth + staticBarWidthOffset) * settings.selectedScreen.backingScaleFactor
        let background    = CIImage(color: .blue).cropped(to: image.extent)

        // 2. SCALE
        let scaled        = image.scale(aspectRatio: 1, scale: scale)

        // 3. BLUR
        let blurred       = scaled.clampedToExtent().applyingGaussianBlur(sigma: blur).cropped(to: scaled.extent)

        // 4a. CROP LEFT
        let finalImage    = blurred
        let cropRectLeft  = CGRect(x: finalImage.extent.width.half - image.extent.width.half + barWidth,
                                   y: finalImage.extent.height.half - image.extent.height.half,
                                   width: barWidth,
                                   height: image.extent.height)
        let left          = finalImage
                .cropped(to: cropRectLeft)
                .transformed(by: CGAffineTransform(translationX: -cropRectLeft.minX, y: -cropRectLeft.minY))
                .composited(over: background)

        // 4b. CROP RIGHT
        let cropRectRight = CGRect(x: finalImage.extent.width.half + image.extent.width.half - 2 * barWidth,
                                   y: finalImage.extent.height.half - image.extent.height.half,
                                   width: barWidth,
                                   height: image.extent.height)
        let right         = finalImage
                .cropped(to: cropRectRight)
                .transformed(by: CGAffineTransform(translationX: -cropRectRight.minX, y: -cropRectRight.minY))
                .composited(over: background)

        // 5. SEND
        imageSubjectLeft.send(left)
        imageSubjectRight.send(right)

        switch settings.previewSource {
            case .input:  imageSubjectFull.send(image)
            case .scaled: imageSubjectFull.send(scaled)
            case .blurred:imageSubjectFull.send(blurred)
            case .left:   imageSubjectFull.send(left)
            case .right:  imageSubjectFull.send(right)
        }
    }
}




