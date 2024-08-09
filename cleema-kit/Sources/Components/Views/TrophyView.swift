//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Models
import NukeUI
import SwiftUI

public struct TrophyView: View {
    var title: String
    var date: Date
    var image: RemoteImage

    public init(title: String, date: Date, image: RemoteImage) {
        self.title = title
        self.date = date
        self.image = image
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            LazyImage(url: image.url, resizingMode: .aspectFit)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    Color.clear
                        .frame(width: 76, height: 76)

                    VStack(spacing: 0) {
                        Text(date.formatted(.dateTime.month(.twoDigits)))
                            .font(.montserratBold(style: .caption, size: 12))

                        Rectangle()
                            .frame(height: 1)

                        Text(date.formatted(.dateTime.year(.twoDigits)))
                            .font(.montserrat(style: .caption, size: 12))
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 7)
                    .foregroundColor(.white)
                    .frame(width: 28)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.montserratBold(style: .caption2, size: 10))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .frame(height: 28)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .dynamicTypeSize(...DynamicTypeSize.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 104, height: 104)
    }
}
