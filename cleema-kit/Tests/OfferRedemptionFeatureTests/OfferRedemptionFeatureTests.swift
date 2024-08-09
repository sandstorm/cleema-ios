//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import OfferRedemptionFeature
import Overture
import XCTest

@MainActor
final class OfferFeatureTests: XCTestCase {
    func testTheFlow() async throws {
        let offer: Offer = .fake()
        let redeemedVoucher = LockIsolated<(Offer.ID, String)?>(nil)

        let requestedOffer = with(
            offer,
            concat(set(\.voucherRedemption, .redeemed(code: "foo", nextRedemptionDate: .now.add(weeks: 1))))
        )

        let store: TestStore = .init(
            initialState: .init(offer: offer),
            reducer: OfferRedemption()
        ) {
            $0.marketplaceClient.requestVoucher = { _ in requestedOffer }
            $0.marketplaceClient.redeemVoucher = {
                redeemedVoucher.setValue(($0, $1))
            }
        }

        await store.send(.requestVoucherButtonTapped) {
            $0.isRequestingVoucher = true
        }

        await store.receive(.requestVoucherResult(.success(requestedOffer))) {
            $0.offer = requestedOffer
            $0.isRequestingVoucher = false
        }

        await store.send(.redeemButtonTapped)

        await store.receive(.redeemResult(.success(true))) {
            $0.isRedemptionAllowed = false
        }
    }
}
