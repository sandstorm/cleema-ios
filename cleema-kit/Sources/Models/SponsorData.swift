//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct SponsorData: Equatable {
    public var firstName: String = ""
    public var lastName: String = ""
    public var streetAndHouseNumber: String = ""
    public var postalCode: String = ""
    public var city: String = ""
    public var iban: String = ""
    public var bic: String = ""

    public var isInvalid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || streetAndHouseNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !iban.isValidIBAN
    }

    public init(
        firstName: String = "",
        lastName: String = "",
        streetAndHouseNumber: String = "",
        postalCode: String = "",
        city: String = "",
        iban: String = "",
        bic: String = ""
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.streetAndHouseNumber = streetAndHouseNumber
        self.postalCode = postalCode
        self.city = city
        self.iban = iban
        self.bic = bic
    }
}

extension String {
    private func mod97() -> Int {
        let symbols: [Character] = Array(self)
        let swapped = symbols.dropFirst(4) + symbols.prefix(4)
        let mod: Int = swapped.reduce(0) { previousMod, char in
            let value = Int(String(char), radix: 36)!
            let factor = value < 10 ? 10 : 100
            let m = (factor * previousMod + value) % 97
            return m
        }

        return mod
    }

    public var isValidIBAN: Bool {
        guard count >= 4, count <= 34 else {
            return false
        }
        let uppercase = uppercased()
        guard uppercase.range(of: "^[0-9A-Z]*$", options: .regularExpression) != nil else {
            return false
        }
        return uppercase.mod97() == 1
    }
}
