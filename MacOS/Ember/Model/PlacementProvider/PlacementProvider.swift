// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Cocoa

struct Placement {
    let source: CGRect
    let target: CGRect
    let offset: CGFloat
}

/// This service returns coordinates for the given window type
protocol PlacementProvider {
    func getPlacement(for type: WindowPosition,
                      sourceAspectRatio: AspectRatio,
                      targetScreen: NSScreen) -> Placement
}

/// A simple implementation of the placement provider
/// It only supports a mapping from a 16:9 ratio onto
/// the main screen
class StaticMainDisplayPlacementProvider: PlacementProvider {

    /// Get placement for given type
    func getPlacement(for type: WindowPosition,
                      sourceAspectRatio: AspectRatio,
                      targetScreen: NSScreen) -> Placement {
        let screenWidth  = targetScreen.frame.width
        let screenHeight = targetScreen.frame.height
        let mappedWidth  = screenHeight * sourceAspectRatio.ratio
        assert(mappedWidth > 0)

        let verticalBlackBarWidth = (screenWidth - mappedWidth) / 2.0
        let verticalBlackBarSize  = CGSize(width: verticalBlackBarWidth, height: screenHeight)
        switch type {
            case .left:
                return Placement(source: CGRect(origin: CGPoint(x: verticalBlackBarWidth, y: 0),
                                              size: verticalBlackBarSize),
                               target: CGRect(origin: .zero,
                                              size: verticalBlackBarSize),
                               offset: (-verticalBlackBarWidth) * targetScreen.backingScaleFactor)
            case .right:
                return Placement(source: CGRect(origin: CGPoint(x: screenWidth - verticalBlackBarWidth, y: 0),
                                              size: verticalBlackBarSize),
                               target: CGRect(origin: CGPoint(x: screenWidth - verticalBlackBarWidth, y: 0),
                                              size: verticalBlackBarSize),
                               offset: (-screenWidth + verticalBlackBarWidth * 2) * targetScreen.backingScaleFactor)
        }
    }
}