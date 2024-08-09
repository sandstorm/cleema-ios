//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct OfferResponse: Codable {
    enum StoreType: String, Codable {
        case shop
        case online
    }

    struct Address: Codable {
        var street: String?
        var city: String?
        var zip: String?
        var housenumber: String?
    }

    var uuid: UUID
    var title: String
    var summary: String
    var description: String
    var image: ImageResponse?
    var validFrom: Date
    var region: RegionResponse?
    var location: LocationResponse?
    var address: Address?
    var discount: Int
    var storeType: StoreType
    var genericVoucher: String?
    var voucherRedeem: VoucherRedemptionResponse
    var websiteUrl: String?
}

struct VoucherRedemptionResponse: Codable {
    var redeemAvailableDate: Date?
    var redeemedCode: String?
    var redeemAvailable: Bool
    var vouchersExhausted: Bool
}
