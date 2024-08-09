//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import Models
import NukeUI
import OfferRedemptionFeature
import Styling
import SwiftUI

struct OfferItemView: View {
    var offer: Offer
    @State private var imageWidth: CGFloat = 1

    var body: some View {
        enum ImageID {}

        return GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text(offer.title)
                        .lineLimit(2)
                        .font(.montserratBold(style: .headline, size: 16))
                        .frame(height: 40, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyImage(url: offer.image?.url) { state in
                    Group {
                        if let image: NukeUI.Image = state.image {
                            #if os(iOS)
                            image.resizingMode(ImageResizingMode.aspectFill)
                            #else
                            image
                            #endif
                        } else if state.error != nil {
                            Image(systemName: "exclamationmark.triangle")
                        } else {
                            Image(systemName: "photo")
                        }
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: imageWidth, height: 100)
                #if os(iOS)
                    .background(Color(.systemBackground))
                #endif

                if offer.discount > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(offer.discount)%")
                            .font(.montserratBold(style: .title, size: 24))

                        Text(L10n.Offer.Discount.label)
                            .font(.montserrat(style: .body, size: 14))
                    }

                    Spacer()

                    Text(offer.type.title)
                        .font(.montserrat(style: .caption, size: 8))
                } else {
                    Text(offer.summary)
                        .font(.montserrat(style: .body, size: 14))
                        .lineLimit(3)

                    Spacer()
                }
            }
            .reportSize(ImageID.self) {
                imageWidth = $0.width
            }
        }
        .groupBoxStyle(.plain(padding: 8))
    }
}

struct OfferRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OfferItemView(offer: .fake(imageID: 1))
                .padding()
                .groupBoxStyle(.plain)
                .background(.gray)
        }
    }
}
