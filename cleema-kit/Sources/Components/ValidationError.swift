//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct ValidationError: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let email = ValidationError(rawValue: 1 << 0)
    public static let passwordLength = ValidationError(rawValue: 1 << 1)
    public static let notMatching = ValidationError(rawValue: 1 << 2)
    public static let name = ValidationError(rawValue: 1 << 3)
    public static let region = ValidationError(rawValue: 1 << 4)
    public static let oldPasswordNotMatching = ValidationError(rawValue: 1 << 5)

    public static let all: ValidationError = [
        .email, .passwordLength, .notMatching, .name, .region
    ]
}

public extension ValidationError {
    var hint: String? {
        guard !isEmpty else { return nil }

        if contains(.name) {
            return L10n.Form.Error.nameEmpty
        }
        if contains(.email) {
            return L10n.Form.Error.emailInvalid
        }
        if contains(.passwordLength) {
            return L10n.Form.Error.passwordTooShort
        }
        if contains(.notMatching) {
            return L10n.Form.Error.passwordsDoNotMatch
        }
        if contains(.region) {
            return L10n.Form.Error.noRegionSelected
        }
        if contains(.oldPasswordNotMatching) {
            return L10n.Form.Error.oldPasswordNotMatching
        }

        return nil
    }
}
