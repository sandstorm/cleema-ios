//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models

public struct MarketplaceClient {
    public var requestVoucher: @Sendable (Offer.ID) async throws -> Offer
    public var offers: @Sendable (Region.ID) async throws -> [Offer]
    public var redeemVoucher: @Sendable (Offer.ID, String) async throws -> Void
    public var isVoucherRedeemed: @Sendable (Offer.ID, String) async -> Bool

    public init(
        requestVoucher: @Sendable @escaping (Offer.ID) async throws -> Offer,
        offers: @Sendable @escaping (Region.ID) async throws -> [Offer],
        redeemVoucher: @Sendable @escaping (Offer.ID, String) async throws -> Void,
        isVoucherRedeemed: @Sendable @escaping (Offer.ID, String) async -> Bool
    ) {
        self.requestVoucher = requestVoucher
        self.offers = offers
        self.redeemVoucher = redeemVoucher
        self.isVoucherRedeemed = isVoucherRedeemed
    }
}

import XCTestDynamicOverlay

public extension MarketplaceClient {
    private static let fakeOffers = [
        Offer.fake(imageID: 1),
        .fake(imageID: 2),
        .fake(imageID: 3),
        .fake(imageID: 4),
        .fake(imageID: 5)
    ]

    static let preview: Self = .init(
        requestVoucher: { id in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            return .fake(id: id)
        },
        offers: { _ in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 5)
            return fakeOffers.shuffled()
        },
        redeemVoucher: { _, _ in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 5)
        },
        isVoucherRedeemed: { _, _ in
            true
        }
    )

    static let unimplemented: Self = .init(
        requestVoucher: XCTUnimplemented("\(Self.self).redeem", placeholder: .fake()),
        offers: XCTUnimplemented("\(Self.self).offers", placeholder: []),
        redeemVoucher: XCTUnimplemented("\(Self.self).redeemVoucher"),
        isVoucherRedeemed: XCTUnimplemented("\(Self.self).isVoucherRedeemed")
    )
}

public enum MarketplaceClientKey: TestDependencyKey {
    public static var previewValue = MarketplaceClient.preview
    public static let testValue = MarketplaceClient.unimplemented
}

public extension DependencyValues {
    var marketplaceClient: MarketplaceClient {
        get { self[MarketplaceClientKey.self] }
        set { self[MarketplaceClientKey.self] = newValue }
    }
}
