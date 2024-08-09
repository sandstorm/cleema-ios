//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct AddSponsorMembershipRequest: Codable {
    var supportType: String
    var firstname: String
    var lastname: String
    var street: String
    var zip: String
    var city: String
    var iban: String
    var bic: String?
}

extension AddSponsorMembershipRequest {
    init(packageID: SponsorPackage.ID, sponsorData: SponsorData) {
        self.init(
            supportType: packageID.rawValue,
            firstname: sponsorData.firstName,
            lastname: sponsorData.lastName,
            street: sponsorData.streetAndHouseNumber,
            zip: sponsorData.postalCode,
            city: sponsorData.city,
            iban: sponsorData.iban,
            bic: sponsorData.bic.isEmpty ? nil : sponsorData.bic
        )
    }
}
