//
//  Created by Kumpels and Friends on 28.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Models
import Styling
import SwiftUI

struct ChallengeProgressView: View {
    var userChallenge: JoinedChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text(L10n.Progress.NumberOfUnitsDone.count(userChallenge.numberOfUnitsDone))
                    .font(.montserrat(style: .title, size: 24))
                Text(L10n.Progress.NumberOfUnitsDone.label(userChallenge.unit))
                Text(L10n.Progress.Duration.count(userChallenge.duration))
                    .font(.montserrat(style: .title, size: 24))
                Text(L10n.Progress.Duration.label)
            }

            ProgressView(value: userChallenge.progress)
                .animation(.easeInOut, value: userChallenge.progress)
        }
    }
}

struct ChallengeProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeProgressView(userChallenge: .fake(challenge: .fake(), answers: [0: .succeeded]))
            .padding()
            .cleemaStyle()
    }
}
