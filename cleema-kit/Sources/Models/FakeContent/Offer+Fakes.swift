//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Contacts
import CoreLocation
import Fakes
import Foundation
import Tagged

public extension Offer {
    static func fake(
        id: ID = .init(rawValue: .init()),
        title: String = .words.prefix(Int.random(in: 2 ... 6)).map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .joined(separator: " "),
        summary: String = .sentence(),
        description: String = .sentences.prefix(Int.random(in: 2 ... 4)).joined(separator: ".\n\n"),
        date: Date = .now,
        region: Region = .fake(),
        location: Location = .fake(),
        address: CNPostalAddress = {
            let address = CNMutablePostalAddress()
            address.street = "Sock Street 3"
            address.city = "Dresden"
            address.postalCode = "01097"
            return address
        }(),
        discount: Int = Int.random(in: 5 ... 30),
        imageID: UInt = 1,
        type: Offer.StoreType = Offer.StoreType.allCases.randomElement()!,
        voucherRedemption: Offer.VoucherRedemptionState = .pending,
        websiteUrl: String = "cleema.app"
    ) -> Self {
        .init(
            id: id,
            title: title,
            summary: summary,
            description: description,
            image: RemoteImage.fake(),
            date: date,
            region: region,
            location: location,
            address: address,
            discount: discount,
            type: type,
            voucherRedemption: voucherRedemption,
            websiteUrl: websiteUrl
        )
    }
}
