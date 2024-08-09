//
//  File.swift
//  
//
//  Created by Justin on 08.05.24.
//

import Models
import Styling
import SwiftUI

public struct CollectiveProgressView: View {
    var userChallenge: JoinedChallenge

    public init(userChallenge: JoinedChallenge) {
        self.userChallenge = userChallenge
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text(L10n.Progress.NumberOfUnitsDone.count(Int(userChallenge.collectiveProgress)))
                    .font(.montserrat(style: .title, size: 24))
                Text(L10n.Progress.NumberOfUnitsDone.label(userChallenge.unit))
                Text(L10n.Progress.Duration.count(Int(userChallenge.collectiveGoalAmount)))
                    .font(.montserrat(style: .title, size: 24))
                Text(L10n.Progress.Duration.label)
            }
            
            var progress: Double = (Double(userChallenge.collectiveProgress) /  Double(userChallenge.collectiveGoalAmount)) > 1.0
                ? 1.0 : Double(userChallenge.collectiveProgress) / Double(userChallenge.collectiveGoalAmount)

            ProgressView(value: progress)
                .animation(.easeInOut, value: progress)
        }
    }
}

struct CollectiveProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CollectiveProgressView(userChallenge: .fake(challenge: .fake(), answers: [0: .succeeded]))
            .padding()
            .cleemaStyle()
    }
}

