//
//  Created by Kumpels and Friends on 19.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct Logging {
    public init(
        log: @escaping (
            _ level: Level,
            _ content: Any,
            _ functionName: StaticString,
            _ fileName: StaticString,
            _ lineNumber: Int,
            _ userInfo: [String: Any]?
        ) -> Void
    ) {
        self.log = log
    }

    public enum Level: Int {
        case debug
        case info
        case warning
        case error
        case fatal

        var description: String {
            switch self {
            case .info:
                return "INFO"
            case .debug:
                return "DEBUG"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            case .fatal:
                return "FATAL"
            }
        }
    }

    public var log: (
        _ level: Level,
        _ closure: Any,
        _ functionName: StaticString,
        _ fileName: StaticString,
        _ lineNumber: Int,
        _ userInfo: [String: Any]?
    ) -> Void
}

public extension Logging {
    static let `default`: Self = .init { level, message, function, filename, line, userInfo in
        let date = Date()
        let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .long)
        let source = "\(filename):\(line) – \(function)"
        let levelName = level.description

        print("[\(formattedDate)][\(source)][\(levelName)]", message, userInfo ?? "")
    }

    static let noop: Self = .init { _, _, _, _, _, _ in }

    func info(
        _ message: @autoclosure () -> Any,
        functionName: StaticString = #function,
        fileName: StaticString = #file,
        lineNumber: Int = #line,
        userInfo: [String: Any]? = nil
    ) {
        log(.info, message(), functionName, fileName, lineNumber, userInfo)
    }

    func debug(
        _ message: @autoclosure () -> Any,
        functionName: StaticString = #function,
        fileName: StaticString = #file,
        lineNumber: Int = #line,
        userInfo: [String: Any]? = nil
    ) {
        log(.debug, message(), functionName, fileName, lineNumber, userInfo)
    }

    func warning(
        _ message: @autoclosure () -> Any,
        functionName: StaticString = #function,
        fileName: StaticString = #file,
        lineNumber: Int = #line,
        userInfo: [String: Any]? = nil
    ) {
        log(.warning, message(), functionName, fileName, lineNumber, userInfo)
    }

    func error(
        _ message: @autoclosure () -> Any,
        functionName: StaticString = #function,
        fileName: StaticString = #file,
        lineNumber: Int = #line,
        userInfo: [String: Any]? = nil
    ) {
        log(.error, message(), functionName, fileName, lineNumber, userInfo)
    }

    func fatal(
        _ message: @autoclosure () -> Any,
        functionName: StaticString = #function,
        fileName: StaticString = #file,
        lineNumber: Int = #line,
        userInfo: [String: Any]? = nil
    ) {
        log(.fatal, message(), functionName, fileName, lineNumber, userInfo)
    }
}

public extension Error {
    var logInfo: [String: Any] {
        ["error": self]
    }
}

import Dependencies
import XCTestDynamicOverlay

extension Logging {
    static let unimplemented: Self = .init { level, content, _, _, _, userInfo in
        let unimpl: (Level, Any, [String: Any]?) -> Void = XCTestDynamicOverlay
            .unimplemented("\(Self.self).log invoked")
        unimpl(level, content, userInfo)
    }
}

public enum LoggingKey: TestDependencyKey {
    public static let testValue = Logging.unimplemented
    public static let previewValue = Logging.noop
}

public extension DependencyValues {
    var log: Logging {
        get { self[LoggingKey.self] }
        set { self[LoggingKey.self] = newValue }
    }
}

extension LoggingKey: DependencyKey {
    public static let liveValue: Logging = .default
}
