//
//  Created by Kumpels and Friends on 08.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Contacts
import Foundation
import Tagged

public struct Offer: Equatable, Identifiable {
    public typealias ID = Tagged<Offer, UUID>

    public enum StoreType: Equatable, CaseIterable {
        case shop
        case online
    }

    public enum VoucherRedemptionState: Equatable, Codable {
        case pending
        case redeemed(code: String, nextRedemptionDate: Date?)
        case exhausted
        case generic(code: String)
    }

    public var id: ID
    public var title: String
    public var summary: String
    public var description: String
    public var image: RemoteImage?
    public var date: Date
    public var region: Region?
    public var location: Location?
    public var address: CNPostalAddress
    public var discount: Int
    public var type: StoreType
    public var voucherRedemption: VoucherRedemptionState
    public var websiteUrl: String?

    public init(
        id: ID,
        title: String,
        summary: String,
        description: String,
        image: RemoteImage?,
        date: Date,
        region: Region?,
        location: Location?,
        address: CNPostalAddress,
        discount: Int,
        type: StoreType = .online,
        voucherRedemption: VoucherRedemptionState,
        websiteUrl: String?
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.description = description
        self.image = image
        self.date = date
        self.region = region
        self.location = location
        self.address = address
        self.discount = discount
        self.type = type
        self.voucherRedemption = voucherRedemption
        self.websiteUrl = websiteUrl
    }
}
