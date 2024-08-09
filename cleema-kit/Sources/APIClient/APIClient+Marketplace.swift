//
//  Created by Kumpels and Friends on 26.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Logging
import Models

public extension APIClient {
    @Sendable
    func offers(regionID: Region.ID) async throws -> [Offer] {
        let result: [OfferResponse] = try await decoded(
            for: .marketplace(.offers(regionID.rawValue)),
            with: token
        )
        return result.compactMap {
            Offer(rawValue: $0, baseURL: baseURL)
        }
    }

    @Sendable
    func redeem(voucherID: Offer.ID) async throws -> Offer {
        let response: OfferResponse = try await decoded(
            for: .marketplace(.redeem(voucherID.rawValue)),
            with: token
        )
        guard let offer = Offer(rawValue: response, baseURL: baseURL)
        else { throw InvalidResponse("OfferResponse not convertible to Offer.") }
        return offer
    }
}
