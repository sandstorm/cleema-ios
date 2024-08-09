//
//  Created by Kumpels and Friends on 31.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import MarketplaceClient
import Models
import Styling
import SwiftUI
import UniformTypeIdentifiers

// MARK: - State

public struct OfferRedemption: ReducerProtocol {
    public struct State: Equatable {
        public init(offer: Offer, isRequestingVoucher: Bool = false, isRedemptionAllowed: Bool = true) {
            self.offer = offer
            self.isRequestingVoucher = isRequestingVoucher
            self.isRedemptionAllowed = isRedemptionAllowed
        }

        public var offer: Offer
        public var isRequestingVoucher: Bool = false
        public var isRedemptionAllowed: Bool = true
    }

    public enum Action: Equatable {
        case requestVoucherButtonTapped
        case redeemButtonTapped
        case requestVoucherResult(TaskResult<Offer>)
        case redeemResult(TaskResult<Bool>)
    }

    @Dependency(\.marketplaceClient) private var marketplaceClient
    @Dependency(\.log) private var log

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .requestVoucherButtonTapped:
            guard case .pending = state.offer.voucherRedemption else { return .none }
            state.isRequestingVoucher = true
            return .task { [id = state.offer.id] in
                await .requestVoucherResult(
                    TaskResult {
                        try await marketplaceClient.requestVoucher(id)
                    }
                )
            }
            .animation(.default)
        case let .requestVoucherResult(.success(offer)):
            state.isRequestingVoucher = false
            state.offer = offer
            return .none
        case let .requestVoucherResult(.failure(error)):
            state.isRequestingVoucher = false
            return .fireAndForget {
                log.error("Error redeeming offer.", userInfo: error.logInfo)
            }
        case .redeemButtonTapped:
            guard case let .redeemed(code, _) = state.offer.voucherRedemption else { return .none }
            return .task { [offerID = state.offer.id] in
                .redeemResult(
                    await TaskResult {
                        try await marketplaceClient.redeemVoucher(offerID, code)
                        return true
                    }
                )
            }
            .animation()
        case .redeemResult(.success):
            state.isRedemptionAllowed = false
            return .none
        case .redeemResult:
            return .none
        }
    }
}

// MARK: - View

public struct OfferRedemptionView: View {
    let store: StoreOf<OfferRedemption>

    public init(store: StoreOf<OfferRedemption>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                if viewStore.isRequestingVoucher {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    switch viewStore.offer.voucherRedemption {
                    case let .generic(voucher):
                        redeemVoucherView(viewStore, voucher, isRedeemable: false, url: viewStore.offer.websiteUrl ?? nil)
                            .padding(.vertical)
                    case .pending:
                        voucherPendingView(viewStore)
                            .padding(.vertical)
                    case let .redeemed(voucher, _) where viewStore.isRedemptionAllowed:
                        redeemVoucherView(viewStore, voucher, isRedeemable: true, url: viewStore.offer.websiteUrl ?? nil)
                            .padding(.vertical)
                    case .exhausted, .redeemed:
                        EmptyView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    func voucherPendingView(_ viewStore: ViewStoreOf<OfferRedemption>) -> some View {
        VStack(alignment: .leading) {
            HStack {
                if viewStore.offer.discount > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(viewStore.offer.discount)%")
                            .font(.montserratBold(style: .title, size: 24))

                        Text(L10n.Offer.Discount.label)
                            .font(.montserrat(style: .body, size: 14))
                    }
                }

                Spacer()

                Button(L10n.Button.Request.label) {
                    viewStore.send(.requestVoucherButtonTapped, animation: .default)
                }
            }
            .buttonStyle(.action)

            Text(viewStore.offer.type.title)
                .font(.montserrat(style: .body, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func redeemVoucherView(
        _ viewStore: ViewStoreOf<OfferRedemption>,
        _ voucher: String,
        isRedeemable: Bool,
        url: String? = nil
    ) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                VStack {
                    Spacer()

                    HStack(spacing: 0) {
                        ZStack(alignment: .bottomLeading) {
                            Color.redeemedVoucher
                            if viewStore.offer.discount > 0 {
                                VStack(alignment: .leading) {
                                    Text(L10n.Offer.VoucherCard.headline)
                                        .font(.montserrat(style: .body, size: 14))

                                    Text("\(viewStore.offer.discount)%")
                                        .font(.montserratBold(style: .largeTitle, size: 48))
                                }
                                .foregroundColor(.white)
                                .padding(.bottom, 12)
                                .padding(.leading, 20)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        ZStack(alignment: .topTrailing) {
                            Color.white

                            VStack(alignment: .trailing, spacing: 12) {
                                Text(L10n.Offer.VoucherCard.label)
                                    .font(.montserrat(style: .body, size: 10))
                                    .foregroundColor(.lightGray)
                                Text(voucher)
                                    .font(.montserratBold(style: .body, size: 24))
                                    .foregroundColor(.defaultText)
                                    .padding(.leading)
                                    .lineLimit(4)
                                    .minimumScaleFactor(0.75)
                                
                                if isRedeemable {
                                    Text(L10n.Redemption.info)
                                        .font(.montserrat(style: .body, size: 10))
                                        .multilineTextAlignment(.center)
                                    // This redeem button leads to the Voucher just disappearing into the void forever
                                    //Button {
                                    //    viewStore.send(.redeemButtonTapped, animation: .default)
                                    //} label: {
                                    //    Text(L10n.Button.RedeemNow.label)
                                    //        .fixedSize()
                                    //}
                                    //.buttonStyle(.action(maxWidth: .infinity))
                                    //.padding([.leading, .bottom])
                                }
                                Button {
                                    UIPasteboard.general.setValue(voucher, forPasteboardType: UTType.plainText.identifier)
                                } label: {
                                    Text("Copy")
                                }
                                .buttonStyle(.action(maxWidth: .infinity))
                                .padding(.leading)
                                
                                if let url = url {
                                    Button {
                                        if let website = URL(string: url) {
                                            UIApplication.shared.open(website)
                                            }
                                    } label: {
                                        Text("Website")
                                    }
                                    .buttonStyle(.action(maxWidth: .infinity))
                                    .padding([.leading, .bottom])
                                }
                            }
                            .padding(.top, 12)
                            .padding(.trailing, 20)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 165)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.23), radius: 19, x: 0, y: 12)
                }

                HStack(alignment: .top, spacing: 0) {
                    Image("voucher", bundle: .module)
                        .frame(maxWidth: .infinity)
                    Color.clear
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 254)

            Text(viewStore.offer.type.title)
                .font(.montserrat(style: .body, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview

struct OfferRedemptionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GroupBox {
                Spacer()

                Text("bla bla bla")

                OfferRedemptionView(
                    store: .init(
                        initialState: .init(offer: .fake(voucherRedemption: .pending)),
                        reducer: OfferRedemption()
                    )
                )

                Text("bla bla bla")

                Spacer()
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent)
        .cleemaStyle()
        .previewDisplayName("Not Redeemed")

        ZStack {
            GroupBox {
                Spacer()

                Text("bla bla bla")

                OfferRedemptionView(
                    store: .init(
                        initialState: .init(offer: .fake(voucherRedemption: .redeemed(
                            code: "voucher1",
                            nextRedemptionDate: .now
                        ))),
                        reducer: OfferRedemption()
                    )
                )

                Text("bla bla bla")

                Spacer()
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent)
        .cleemaStyle()
        .previewDisplayName("Requested")

        ZStack {
            GroupBox {
                Spacer()

                Text("bla bla bla")

                OfferRedemptionView(
                    store: .init(
                        initialState: .init(offer: .fake(voucherRedemption: .redeemed(
                            code: "voucher1",
                            nextRedemptionDate: .now
                        )), isRedemptionAllowed: false),
                        reducer: OfferRedemption()
                    )
                )

                Text("bla bla bla")

                Spacer()
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent)
        .cleemaStyle()
        .previewDisplayName("Redeemed")
    }
}
