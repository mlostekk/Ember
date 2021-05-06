// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import Combine

/// Class for logging
public class Log {

    /// The exposed log entry stream
    static var logEntryPublisher: AnyPublisher<Entry, Never> {
        logEntrySubject.eraseToAnyPublisher()
    }

    /// The internal log entry subject
    private static let logEntrySubject = PassthroughSubject<Entry, Never>()

    /// One log entry
    public struct Entry {

        public enum Severity: String {
            case debug = "D"
            case info  = "I"
            case error = "E"
        }

        public let message:      String
        public let severity:     Severity
        public let file:         String
        public let line:         UInt32
        public let isMainThread: Bool

        /// Formatting helper
        public func formatted(short: Bool) -> String {
            let fileName = short ? (file as NSString).lastPathComponent : file
            var prefix   = "\(isMainThread ? "+" : "-")\(severity.rawValue)| \(fileName):\(line)"
            prefix = prefix.padding(toLength: short ? 50 : 125, withPad: " ", startingAt: 0)
            return "\(prefix): \(message)"
        }
    }

    /// Log at debug level
    static func d(_ message: @autoclosure () -> String, _ file: String = #file, _ line: UInt32 = #line) {
        #if DEBUG
            logEntrySubject.send(Entry(message: message(), severity: .debug, file: file, line: line, isMainThread: Thread.isMainThread))
        #endif
    }

    /// Log at info level
    static func i(_ message: @autoclosure () -> String, _ file: String = #file, _ line: UInt32 = #line) {
        logEntrySubject.send(Entry(message: message(), severity: .info, file: file, line: line, isMainThread: Thread.isMainThread))
    }

    /// Log at error level
    static func e(_ message: @autoclosure () -> String, _ file: String = #file, _ line: UInt32 = #line) {
        logEntrySubject.send(Entry(message: message(), severity: .error, file: file, line: line, isMainThread: Thread.isMainThread))
    }
}
