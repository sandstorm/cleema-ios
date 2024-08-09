//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import OfferRedemptionFeature
import SelectRegionFeature
import Styling
import SwiftUI

public struct MarketplaceView: View {
    let store: StoreOf<Marketplace>

    @Environment(\.styleGuide) var styleGuide

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var rowHeights: [Int: CGFloat] = [:]

    public init(store: StoreOf<Marketplace>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                SelectRegionView(
                    store: store
                        .scope(state: \.selectRegionState, action: Marketplace.Action.selectRegion),
                    valuePrefix: L10n.Region.Picker.prefix
                )
                .tint(.defaultText)
                .padding(.horizontal, styleGuide.screenEdgePadding)

                LazyVGrid(
                    columns: [
                        .init(.flexible(), spacing: styleGuide.interItemSpacing, alignment: .top),
                        .init(.flexible(), spacing: styleGuide.interItemSpacing, alignment: .top)
                    ],
                    alignment: .leading,
                    spacing: styleGuide.interItemSpacing
                ) {
                    ForEach(viewStore.offers) { offer in
                        NavigationLink(
                            destination: IfLetStore(
                                store.scope(
                                    state: \.selection?.value,
                                    action: Marketplace.Action.offerRedemption
                                ),
                                then: OfferDetailView.init(store:)
                            ),
                            tag: offer.id,
                            selection: viewStore.binding(
                                get: \.selection?.id,
                                send: Marketplace.Action.setNavigation(selection:)
                            )
                        ) {
                            let row = viewStore.offers.index(id: offer.id)!.quotientAndRemainder(dividingBy: 2).quotient

                            OfferItemView(offer: offer)
                                .reportSize(MarketplaceView.self) { size in
                                    rowHeights[row] = max(size.height, rowHeights[row, default: 0])
                                }
                                .frame(height: rowHeights[row])
                        }
                        .buttonStyle(.listRow)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, styleGuide.screenEdgePadding)
            }
            .task {
                await viewStore.send(.load).finish()
            }
            .refreshable {
                await viewStore.send(.load).finish()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.profileButtonTapped)
                    } label: {
                        Image.profileIcon
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle(L10n.title)
        }
    }
}

// MARK: - Preview

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarketplaceView(
                store: .init(
                    initialState: .init(selectRegionState: .init()),
                    reducer: Marketplace()
                )
            )
            .background(ScreenBackgroundView())
        }
        .groupBoxStyle(.plain)
    }
}
