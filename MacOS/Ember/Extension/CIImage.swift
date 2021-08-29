// Copyright (c) 2021 Nomad5. All rights reserved.

import CoreImage

/// File private static filter
fileprivate let scaleFilter = CIFilter(name: "CILanczosScaleTransform")!

extension CIImage {

    /// Scale image with the lanczos scale transformation
    func scale(aspectRatio: CGFloat, scale: CGFloat) -> CIImage {
        scaleFilter.setValue(self, forKey: kCIInputImageKey)
        scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
        scaleFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return scaleFilter.outputImage!
    }
}
