//
//  Created by Kumpels and Friends on 14.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Models

public extension Offer.StoreType {
    var title: String {
        switch self {
        case .shop:
            return L10n.Offer.OfferType.Shop.title
        case .online:
            return L10n.Offer.OfferType.Online.title
        }
    }
}
