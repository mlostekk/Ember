// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

/// Window placement types
enum PlacementType {
    case left
    case right
    case settings
}

struct Mapping {
    let source: CGRect
    let target: CGRect
    let offset: Int
}

/// This service returns coordinates for the given window type
protocol PlacementProvider {

    func getPlacement(for type: PlacementType) -> Mapping
}

/// A simple implementation of the placement provider
/// It only supports a mapping from a 16:9 ratio onto
/// the main screen
class StaticMainDisplayPlacementProvider: PlacementProvider {

    struct AspectRatio {
        let width:  CGFloat
        let height: CGFloat
        var ratio:  CGFloat {
            width / height
        }
    }

    let aspectRatio16to9 = AspectRatio(width: 16, height: 9)

    /// Get placement for given type
    func getPlacement(for type: PlacementType) -> Mapping {
        guard let screen = NSScreen.main else {
            fatalError("No main screen found")
        }
        let screenWidth  = screen.frame.width
        let screenHeight = screen.frame.height
        let mappedWidth  = screenHeight * aspectRatio16to9.ratio

        let verticalBlackBarWidth = (screenWidth - mappedWidth) / 2.0
        let verticalBlackBarSize  = CGSize(width: verticalBlackBarWidth, height: screenHeight)
        switch type {
            case .left:
                return Mapping(source: CGRect(origin: CGPoint(x: verticalBlackBarWidth, y: 0),
                                              size: verticalBlackBarSize),
                               target: CGRect(origin: .zero,
                                              size: verticalBlackBarSize),
                               offset: -440)
            case .right:
                return Mapping(source: CGRect(origin: CGPoint(x: screenWidth - verticalBlackBarWidth, y: 0),
                                              size: verticalBlackBarSize),
                               target: CGRect(origin: CGPoint(x: screenWidth - verticalBlackBarWidth, y: 0),
                                              size: verticalBlackBarSize),
                               offset: -2560)
            case .settings:
                let size = NSSize(width: 400, height: 400)
                return Mapping(source: .zero,
                               target: CGRect(origin: CGPoint(x: screen.frame.midX - size.width / 2.0,
                                                              y: screen.frame.midY - size.height / 2.0),
                                              size: size),
                               offset: 0)
        }
    }
}