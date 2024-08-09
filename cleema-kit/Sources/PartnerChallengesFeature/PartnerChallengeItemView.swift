//
//  Created by Kumpels and Friends on 23.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import Models
import NukeUI
import SwiftUI

public struct PartnerChallengeItemView: View {
    var challenge: Challenge

    public var body: some View {
        GroupBox {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    CustomLazyImage(url: challenge.image?.image.url)
                        .frame(height: 225)

                    VStack(alignment: .leading) {
                        Text(challenge.title)
                            .font(.montserratBold(style: .headline, size: 16))
                            .padding(.bottom, 4)

                        Text(challenge.teaserText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Divider()

                        HStack(alignment: .bottom) {
                            LabeledContentView(
                                horizontalFixed: false,
                                L10n.Item.Partner.label,
                                value: challenge.sponsor?.title ?? L10n.Item.Partner.Title.defaultValue
                            )

                            Spacer()

                            if let remoteImage = challenge.sponsor?.logo {
                                LazyImage(url: remoteImage.url) { state in
                                    if let image = state.image {
                                        image
                                            .resizingMode(.aspectFit)
                                    }
                                }
                                .frame(width: 100, height: 36, alignment: .bottomTrailing)
                            }
                        }
                    }
                    .padding(20)
                }

                BadgeView(text: challenge.endDate > Date() ? challenge.startDate.formatted(date: .numeric, time: .omitted) : L10n.Item.Date.Label.finished, color: .news)
            }
        }
        .groupBoxStyle(.plain(padding: 0))
    }
}
