//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import Models
import Styling
import SwiftUI

public struct JoinedChallengeItemView: View {
    var joinedChallenge: JoinedChallenge

    @Environment(\.styleGuide) var styleGuide

    public init(joinedChallenge: JoinedChallenge) {
        self.joinedChallenge = joinedChallenge
    }

    public var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(joinedChallenge.challenge.title)
                    .font(.montserrat(style: .title, size: 16))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .layoutPriority(0)

                Text(joinedChallenge.challenge.teaserText)
                    .font(.montserrat(style: .footnote, size: 12))
            }

            Spacer()

            VerticalProgressView(value: getProgress(), total: getTotal()) {
                Image(systemName: "arrow.right")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 8)
            }
            .accentColor(.dimmed)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .aspectRatio(1, contentMode: .fit)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.regularMaterial)
        }
    }
    
    public func getProgress() -> Double {
        if case .collective(_) = joinedChallenge.kind {
            let progress: Double = Double(joinedChallenge.collectiveProgress) / Double(joinedChallenge.collectiveGoalAmount)
            return progress > 1.0 ? 1.0 : progress
        }
        return joinedChallenge.progress
    }
    
    public func getTotal() -> Double {
        return 1.0
    }
}

struct UserChallengeItemView_Previews: PreviewProvider {
    static var previews: some View {
        JoinedChallengeItemView(joinedChallenge: .init(challenge: .fake(title: "Eating no ants for a whole month")))
            .frame(width: 150)
            .border(.red)
    }
}
