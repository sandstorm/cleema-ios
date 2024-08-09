//
//  Created by Kumpels and Friends on 02.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import Styling
import SwiftUI
import SwiftUINavigation

struct SurveyView: View {
    let store: StoreOf<SurveyFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.state.state {
            case .participation:
                SurveyCardView(survey: viewStore.state) {
                    viewStore.send(.participateTapped)
                }

            case .evaluation:
                SurveyCardView(survey: viewStore.state) {
                    viewStore.send(.evaluationTapped)
                }
            }
        }
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView(store: .init(initialState: .fake(), reducer: SurveyFeature()))
    }
}
