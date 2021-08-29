// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import Cocoa

struct AspectRatio: CustomStringConvertible, Hashable {
    let width:  CGFloat
    let height: CGFloat
    var ratio:  CGFloat {
        width / height
    }
    static let aspectRatio16to9 = AspectRatio(width: 16, height: 9)
    static let aspectRatio4to3  = AspectRatio(width: 4, height: 3)

    var description: String {
        "\(width):\(height)"
    }
}

class Settings: Service, ObservableObject {

    enum PreviewSource: String, Equatable, CaseIterable {
        case input
        case scaled
        case blurred
        case left
        case right

        var localizedName: String {
            rawValue
        }
    }

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: Settings.self)

    @Published var blurAmount: Double = 10.0
    @Published var scale:      Double = 1.1

    @Published var frameRate:         Double      = 60
    @Published var selectedScreen:    NSScreen    = NSScreen.main!
    @Published var sourceAspectRatio: AspectRatio = .aspectRatio4to3

    @Published var ledCountVertical:   Int = 17
    @Published var ledCountHorizontal: Int = 45
    @Published var ledSourceInset:     Int = 1

    @Published var serialPortEnabled: Bool   = false
    @Published var serialPort:        String = "/dev/cu.usbmodem14301"

    @Published var previewSource: PreviewSource = .input

}
