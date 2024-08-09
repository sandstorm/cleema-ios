//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import MarketplaceFeature
import Models
import OfferRedemptionFeature
import XCTest
import XCTestDynamicOverlay

@MainActor
final class MarketplaceFeatureTests: XCTestCase {
    func testFeature() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: Marketplace()
        )

        let expectedOffers: [Offer] = [
            .fake(),
            .fake(),
            .fake()
        ]
        let invokedRegionID = ActorIsolated<Region.ID?>(nil)
        store.dependencies.marketplaceClient.offers = { id in
            await invokedRegionID.setValue(id)
            return expectedOffers
        }

        await store.send(.selectRegion(.binding(.set(\.$selectedRegion, .leipzig)))) {
            $0.selectRegionState.selectedRegion = .leipzig
        }

        await store.receive(.load) {
            $0.isLoading = true
        }
        await invokedRegionID.withValue {
            XCTAssertEqual(Region.leipzig.id, $0)
        }

        await store.receive(.loadingResponse(.success(expectedOffers))) {
            $0.offers = .init(uniqueElements: expectedOffers)
            $0.isLoading = false
        }
    }

    func testAlreadyRedeemedVoucher() async throws {
        let date = LockIsolated(Date.now)
        let offer: Offer =
            .fake(voucherRedemption: .redeemed(code: "foo", nextRedemptionDate: date.value.add(weeks: 1)))

        let isVoucherRedeemedInvoked = LockIsolated(false)

        let store = TestStore(
            initialState: Marketplace.State(offers: [offer]),
            reducer: Marketplace()
        ) {
            $0.marketplaceClient.isVoucherRedeemed = { _, _ in
                isVoucherRedeemedInvoked.setValue(true)
                return true
            }
            $0.date = .constant(date.value)
        }

        await store.send(.setNavigation(selection: offer.id))

        await store.receive(.navigateToOffer(.init(offer: offer, isRedemptionAllowed: false))) {
            $0.selection = .init(OfferRedemption.State(offer: offer, isRedemptionAllowed: false), id: offer.id)
        }

        XCTAssertTrue(isVoucherRedeemedInvoked.value)

        await store.send(.setNavigation(selection: nil)) {
            $0.selection = nil
        }

        isVoucherRedeemedInvoked.setValue(false)
        date.setValue(Date.now.add(weeks: 1))

        store.dependencies.date = .constant(date.value)
        store.dependencies.marketplaceClient.isVoucherRedeemed = { _, _ in
            isVoucherRedeemedInvoked.setValue(true)
            return true
        }

        await store.send(.setNavigation(selection: offer.id))

        await store.receive(.navigateToOffer(.init(offer: offer, isRedemptionAllowed: true))) {
            $0.selection = .init(OfferRedemption.State(offer: offer, isRedemptionAllowed: true), id: offer.id)
        }

        XCTAssertFalse(isVoucherRedeemedInvoked.value)
    }

    func testAlreadyRedeemedVoucherWithNoNextRedemptionDate() async throws {
        let offer: Offer = .fake(voucherRedemption: .redeemed(code: "foo", nextRedemptionDate: nil))

        let isVoucherRedeemedInvoked = LockIsolated(false)

        let store = TestStore(
            initialState: Marketplace.State(offers: [offer]),
            reducer: Marketplace()
        ) {
            $0.marketplaceClient.isVoucherRedeemed = { _, _ in
                isVoucherRedeemedInvoked.setValue(true)
                return true
            }
        }

        await store.send(.setNavigation(selection: offer.id))

        await store.receive(.navigateToOffer(.init(offer: offer, isRedemptionAllowed: false))) {
            $0.selection = .init(OfferRedemption.State(offer: offer, isRedemptionAllowed: false), id: offer.id)
        }

        XCTAssertTrue(isVoucherRedeemedInvoked.value)

        await store.send(.setNavigation(selection: nil)) {
            $0.selection = nil
        }

        isVoucherRedeemedInvoked.setValue(false)

        store.dependencies.marketplaceClient.isVoucherRedeemed = { _, _ in
            isVoucherRedeemedInvoked.setValue(true)
            return true
        }

        await store.send(.setNavigation(selection: offer.id))

        await store.receive(.navigateToOffer(.init(offer: offer, isRedemptionAllowed: false))) {
            $0.selection = .init(OfferRedemption.State(offer: offer, isRedemptionAllowed: false), id: offer.id)
        }

        XCTAssertTrue(isVoucherRedeemedInvoked.value)
    }
}
