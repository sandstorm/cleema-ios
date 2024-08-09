//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct EmailValidator {
    public var validate: @Sendable (_ text: String) -> String?

    public init(validate: @escaping @Sendable (_: String) -> String?) {
        self.validate = validate
    }
}

import XCTestDynamicOverlay

extension DependencyValues {
    public var emailValidator: EmailValidator {
        get { self[EmailValidatorKey.self] }
        set { self[EmailValidatorKey.self] = newValue }
    }

    private enum EmailValidatorKey: DependencyKey {
        static let liveValue = EmailValidator.live
        static let testValue = EmailValidator.unimplemented
    }
}

public extension EmailValidator {
    static let unimplemented: Self = .init(
        validate: XCTestDynamicOverlay
            .unimplemented("\(Self.self).validate", placeholder: nil)
    )

    static let live: Self = .init { text in
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let allMatches = NSDataDetector.link.matches(
            in: trimmedText,
            options: [],
            // TODO: use NSRange initializer
            range: NSMakeRange(0, NSString(string: trimmedText).length)
        )

        guard
            allMatches.count == 1,
            allMatches.first?.url?.absoluteString.contains("mailto:") == true
        else { return nil }
        return trimmedText
    }

    static let failing: Self = .init(validate: { _ in nil })
    static let alwaysValid: Self = .init(validate: { $0 })
}

private extension NSDataDetector {
    static var link: NSDataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
}
