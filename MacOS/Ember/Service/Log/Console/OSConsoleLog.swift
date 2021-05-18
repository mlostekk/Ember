// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine
import os

/// Console logger
class OSConsoleLog {

    /// The subscription
    private let logSubscription: AnyCancellable

    /// Construction
    public init(with logPublisher: AnyPublisher<Log.Entry, Never>) {
        logSubscription = logPublisher.sink { entry in
            var logType: OSLogType = .info
            switch entry.severity {
                case .debug: logType = .debug
                case .info: logType = .info
                case .error: logType = .error
            }
            os_log("%@", type: logType, entry.formatted(short: false))
        }
    }
}