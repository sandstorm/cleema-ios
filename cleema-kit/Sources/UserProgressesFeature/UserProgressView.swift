//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models
import NukeUI
import Styling
import SwiftUI

struct UserProgressView: View {
    var userProgress: UserProgress
    var maxAllowedAnswers: Int

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // TODO: We should extract an avatar image view
            LazyImage(url: userProgress.user.avatar?.url) { state in
                if let image = state.image {
                    image
                        .resizingMode(.aspectFit)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(userProgress.user.username)
                    .font(.montserratBold(style: .body, size: 12))

                ProgressView(
                    value: Double(userProgress.succeededAnswers) /
                        Double(maxAllowedAnswers)
                )

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(userProgress.succeededAnswers))
                        .font(.montserrat(style: .title, size: 16))
                    Text(L10n.Progress.NumberOfUnitsDone.label)
                        .font(.montserrat(style: .title, size: 12))
                    Text(String(maxAllowedAnswers))
                        .font(.montserrat(style: .title, size: 16))
                    Text(L10n.Progress.Duration.label)
                }
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
        }
    }
}

struct UserProgressView_Previews: PreviewProvider {
    static var previews: some View {
        UserProgressView(
            userProgress: .init(totalAnswers: 10, succeededAnswers: 5, user: .fake()),
            maxAllowedAnswers: 10
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .cleemaStyle()
    }
}
