//
//  Created by Kumpels and Friends on 18.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import MapKit
import MarkdownUI
import Models
import NukeUI
import Styling
import SwiftUI

public struct OfferDetailView: View {
    let store: StoreOf<OfferRedemption>
    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<OfferRedemption>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    LazyImage(url: viewStore.offer.image?.url, resizingMode: .aspectFill)
                        .frame(height: 142)
                        .frame(maxWidth: .infinity)
                    #if os(iOS)
                        .background(Color(.secondarySystemBackground))
                    #endif

                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewStore.offer.title)
                            .font(.montserratBold(style: .body, size: 16))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(viewStore.offer.summary)
                            .font(.montserrat(style: .body, size: 16))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        OfferRedemptionView(store: store)

                        Markdown(viewStore.offer.description)
                            .font(.montserrat(style: .body, size: 16))
                            .accentColor(.action)

                        if let location = viewStore.offer.location {
                            VStack(alignment: .leading, spacing: 16) {
                                Divider()

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(location.title)
                                        .bold()
                                    Text(viewStore.offer.formattedAddress)
                                }

                                Button {
                                    let mapItem = MKMapItem(
                                        placemark: MKPlacemark(
                                            coordinate: location.coordinate,
                                            addressDictionary: nil
                                        )
                                    )
                                    mapItem.name = location.title
                                    mapItem
                                        .openInMaps(
                                            launchOptions: [
                                                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                                            ]
                                        )
                                } label: {
                                    Map(
                                        coordinateRegion: .constant(
                                            MKCoordinateRegion(
                                                center: location.coordinate,
                                                span: MKCoordinateSpan(
                                                    latitudeDelta: 0.02,
                                                    longitudeDelta: 0.02
                                                )
                                            )
                                        ),
                                        interactionModes: [],
                                        annotationItems: [location]
                                    ) { location in
                                        MapMarker(coordinate: location.coordinate, tint: Color.dimmed)
                                    }
                                    .frame(height: 180)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: .infinity)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .cardShadow()
                .padding(.horizontal, styleGuide.screenEdgePadding)
                .padding(.vertical)
            }
            .background(ScreenBackgroundView())
        }
    }
}

import Contacts
extension Offer {
    var formattedAddress: String {
        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: address)
    }
}

// MARK: - Preview

struct OfferDetailView_Previews: PreviewProvider {
    static var previews: some View {
        OfferDetailView(
            store: Store(
                initialState: .init(offer: .fake(imageID: 1)),
                reducer: OfferRedemption()
            )
        )
        .groupBoxStyle(.plain)
    }
}
