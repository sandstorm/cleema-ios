//
//  Created by Kumpels and Friends on 28.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Components
import NukeUI
import SwiftUI

struct DashboardItemView: View {
    var content: DashboardGrid.Item

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 2) {
                Text(content.title)
                    .font(.montserrat(style: .subheadline, size: 14))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                Text(content.text)
                    .font(.montserrat(style: .body, size: 14).leading(.loose))
                    .multilineTextAlignment(.leading)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .aspectRatio(1, contentMode: .fit)
        .padding(8)
        .overlay(alignment: .topTrailing) {
            BadgeView(text: content.badge)
                .foregroundColor(.action)
        }
        .background {
            ZStack(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(.background)
                content.dimension.waveImage?
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: content.isWaveMirrored ? -1 : 1)

                if let remoteImage = content.image {
                    LazyImage(url: remoteImage.url) { state in
                        if let image = state.image {
                            image
                                .resizingMode(.aspectFit)
                        }
                    }
                    .frame(width: remoteImage.width, height: remoteImage.height)
                    .padding(.trailing, 10)
                    .padding(.bottom, 18)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .cardShadow()
    }
}
