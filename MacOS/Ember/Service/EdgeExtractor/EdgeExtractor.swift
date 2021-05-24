// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import CoreImage

/// All edges are from left to right / top to bottom
struct Edges {
    let top:    Array<Color>
    let right:  Array<Color>
    let bottom: Array<Color>
    let left:   Array<Color>

    static let empty = Edges(top: [], right: [], bottom: [], left: [])
}

protocol EdgeExtractor {
    /// Pass in an image, get the edge info
    func extract(from image: CIImage) -> Edges
}

/// Simple implementation
class SimpleEdgeExtractor: EdgeExtractor {

    /// Injected dependencies
    private let settings: Settings

    /// Resize filter
    private let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!

    /// Context needed for color extraction
    private let context      = CIContext(options: [.workingColorSpace: kCFNull as Any])

    /// Construction with dependencies
    init(settings: Settings) {
        self.settings = settings
    }

    /// Main trigger
    func extract(from image: CIImage) -> Edges {
        // scale down image
        let targetSize  = CGSize(width: settings.ledCountHorizontal, height: settings.ledCountVertical)
        let scale       = targetSize.height / image.extent.height
        let aspectRatio = targetSize.width / (image.extent.width * scale)
        resizeFilter.setValue(image, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        guard let resizedImage = resizeFilter.outputImage else {
            Log.i("Could not resize image")
            return .empty
        }
        // TODO this is a stupid, expensive approach, refactor me
        let inset        = settings.ledSourceInset
        // bottom
        var bottomColors = [Color]()
        if true {
            var bitmap = [UInt8](repeating: 0, count: 4 * 45)
            context.render(resizedImage, toBitmap: &bitmap, rowBytes: 180, bounds: CGRect(x: 0, y: 0 + inset, width: 45, height: 1), format: .RGBA8, colorSpace: nil)
            for index in (0..<45) {
                let offset = index * 4
                bottomColors.append(Color(red: max(2, bitmap[offset + 0]),
                                          green: max(2, bitmap[offset + 1]),
                                          blue: max(2, bitmap[offset + 2])))
            }
        }

        // left
        var leftColors = [Color]()
        if true {
            var bitmap = [UInt8](repeating: 0, count: 4 * 17)
            context.render(resizedImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0 + inset, y: 0, width: 1, height: 17), format: .RGBA8, colorSpace: nil)
            for index in (0..<17) {
                let offset = index * 4
                leftColors.append(Color(red: max(2, bitmap[offset + 0]),
                                        green: max(2, bitmap[offset + 1]),
                                        blue: max(2, bitmap[offset + 2])))
            }
        }

        // top
        var topColors = [Color]()
        if true {
            var bitmap = [UInt8](repeating: 0, count: 4 * 45)
            context.render(resizedImage, toBitmap: &bitmap, rowBytes: 180, bounds: CGRect(x: 0, y: 16 - inset, width: 45, height: 1), format: .RGBA8, colorSpace: nil)
            for index in 0..<45 {
                let offset = index * 4
                topColors.append(Color(red: max(2, bitmap[offset + 0]),
                                       green: max(2, bitmap[offset + 1]),
                                       blue: max(2, bitmap[offset + 2])))
            }
        }

        // right
        var rightColors = [Color]()
        if true {
            var bitmap = [UInt8](repeating: 0, count: 4 * 17)
            context.render(resizedImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 44 - inset, y: 0, width: 1, height: 17), format: .RGBA8, colorSpace: nil)
            for index in 0..<17 {
                let offset = index * 4
                rightColors.append(Color(red: max(2, bitmap[offset + 0]),
                                         green: max(2, bitmap[offset + 1]),
                                         blue: max(2, bitmap[offset + 2])))
            }
        }
        return Edges(top: topColors,
                     right: rightColors,
                     bottom: bottomColors,
                     left: leftColors)
    }
}