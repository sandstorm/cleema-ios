//
//  Created by Kumpels and Friends on 26.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import Foundation
import MarketplaceClient

public extension MarketplaceClient {
    static func from(_ client: APIClient, userDefaults: UserDefaults) -> Self {
        .init(
            requestVoucher: client.redeem,
            offers: client.offers,
            redeemVoucher: { offerID, code in
                userDefaults.redeemedVouchers[offerID] = code
            },
            isVoucherRedeemed: { offerID, code in
                userDefaults.redeemedVouchers[offerID] == code
            }
        )
    }
}

extension UserDefaults {
    var redeemedVouchers: [Offer.ID: String] {
        get {
            guard let data = data(forKey: "redeemedVouchers") else { return [:] }
            return (try? JSONDecoder().decode([Offer.ID: String].self, from: data)) ?? [:]
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            set(data, forKey: "redeemedVouchers")
        }
    }
}
