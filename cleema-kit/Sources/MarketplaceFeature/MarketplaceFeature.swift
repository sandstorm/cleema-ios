//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Fakes
import Foundation
import Logging
import Models
import OfferRedemptionFeature
import SelectRegionFeature

public struct Marketplace: ReducerProtocol {
    public struct State: Equatable {
        public init(
            offers: IdentifiedArrayOf<Offer> = [],
            isLoading: Bool = false,
            selection: Identified<Offer.ID, OfferRedemption.State>? = nil,
            selectRegionState: SelectRegion.State = .init()
        ) {
            self.offers = offers
            self.isLoading = isLoading
            self.selection = selection
            self.selectRegionState = selectRegionState
        }

        public var offers: IdentifiedArrayOf<Offer> = []
        public var isLoading = false
        public var selection: Identified<Offer.ID, OfferRedemption.State>?
        public var selectRegionState: SelectRegion.State
    }

    public enum Action: Equatable {
        case load
        case loadingResponse(TaskResult<[Offer]>)
        case setNavigation(selection: Offer.ID?)
        case offerRedemption(OfferRedemption.Action)
        case profileButtonTapped
        case selectRegion(SelectRegion.Action)
        case navigateToOffer(OfferRedemption.State)
    }

    @Dependency(\.marketplaceClient.offers) private var offers
    @Dependency(\.marketplaceClient.isVoucherRedeemed) private var isVoucherRedeemed
    @Dependency(\.log) private var log
    @Dependency(\.date.now) private var now

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.selectRegionState, action: /Action.selectRegion) {
            SelectRegion()
        }

        Reduce { state, action in
            switch action {
            case .load:
                guard let id = state.selectRegionState.selectedRegion?.id else { return .none }
                state.isLoading = true
                return .task {
                    await .loadingResponse(
                        TaskResult {
                            try await offers(id)
                        }
                    )
                }
                .animation(state.offers.isEmpty ? nil : .spring())
            case let .loadingResponse(.success(offers)):
                state.isLoading = false
                state.offers = .init(uniqueElements: offers)
                return .none
            case let .loadingResponse(.failure(error)):
                state.isLoading = false
                return .fireAndForget {
                    log.error("Error loading offers", userInfo: error.logInfo)
                }
            case let .setNavigation(selection: .some(offerID)):
                guard let offer = state.offers[id: offerID] else { return .none }

                return .task {
                    if case let .redeemed(code, nextRedemptionDate) = offer.voucherRedemption {
                        if let nextRedemptionDate {
                            if nextRedemptionDate > now {
                                let isVoucherRedeemed = await isVoucherRedeemed(offerID, code)
                                return .navigateToOffer(.init(offer: offer, isRedemptionAllowed: !isVoucherRedeemed))
                            } else {
                                return .navigateToOffer(.init(offer: offer))
                            }
                        } else {
                            return await .navigateToOffer(.init(
                                offer: offer,
                                isRedemptionAllowed: !isVoucherRedeemed(offerID, code)
                            ))
                        }
                    } else {
                        return .navigateToOffer(.init(offer: offer))
                    }
                }
            case .setNavigation(selection: .none):
                state.selection = nil
                return .none
            case let .navigateToOffer(offerRedemptionState):
                state.selection = Identified(offerRedemptionState, id: offerRedemptionState.offer.id)
                return .none
            case .offerRedemption:
                return .none
            case .profileButtonTapped:
                return .none
            case .selectRegion(.binding):
                return .task { .load }
            case .selectRegion:
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.offerRedemption) {
            Scope(state: \Identified.value, action: .self) {
                OfferRedemption()
            }
        }
    }
}
