// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import Cocoa

class Actions: Service, ObservableObject {

    /// The unique service key
    private(set) static var uniqueKey: String = String(describing: Actions.self)

    var startRenderingStream: AnyPublisher<Void, Never> {
        startRenderingSubject.eraseToAnyPublisher()
    }

    @Published private(set) var startRenderingSubject = PassthroughSubject<Void, Never>()


}
