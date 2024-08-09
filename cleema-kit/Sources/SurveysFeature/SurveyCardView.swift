//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Models
import SwiftUI

struct SurveyCardView: View {
    var survey: Survey
    var action: () -> Void

    @Environment(\.styleGuide) var styleGuide

    var body: some View {
        GroupBox(survey.cardTitle) {
            VStack(alignment: .trailing) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(survey.title)
                    Text(survey.description)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .font(.montserrat(style: .body, size: 14).leading(.loose))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Spacer()

                Button(survey.buttonTitle, action: action)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .buttonStyle(.action)
        .frame(width: styleGuide.singleColumnWidth)
        .groupBoxStyle(.largeWave)
    }
}

extension Survey {
    var cardTitle: String {
        switch state {
        case .participation:
            return L10n.CardTitle.State.participation
        case .evaluation:
            return L10n.CardTitle.State.evaluation
        }
    }

    var buttonTitle: String {
        switch state {
        case .participation:
            return L10n.Card.Action.participation
        case .evaluation:
            return L10n.Card.Action.evaluation
        }
    }
}

struct SurveyCardView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyCardView(survey: .fake()) {}
            .cleemaStyle()
    }
}
