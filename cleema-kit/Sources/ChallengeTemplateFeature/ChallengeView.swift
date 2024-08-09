//
//  Created by Kumpels and Friends on 12.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import Models
import NukeUI
import SwiftUI

struct ChallengeView: View {
    var challenge: Challenge

    @State private var desiredHeight: CGFloat = 0
    @State private var width: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(challenge.title)
                    .font(.montserratBold(style: .headline, size: 14))
                    .multilineTextAlignment(.leading)
                    .allowsTightening(true)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(challenge.teaserText)
                    .font(.caption)
                    .multilineTextAlignment(.leading)

                if let image = challenge.sponsor?.logo {
                    HStack(spacing: 0) {
                        Spacer()
                        LazyImage(url: image.url, resizingMode: .aspectFit)
                            .frame(width: image.width * 20 / image.height, height: 20, alignment: .trailing)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .aspectRatio(1, contentMode: .fit)
        .reportSize(ChallengeView.self) {
            width = $0.width
        }
        .padding(8)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: Preview

import Fakes

struct ChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeView(challenge: .fake())
            .frame(width: 150)
    }
}
