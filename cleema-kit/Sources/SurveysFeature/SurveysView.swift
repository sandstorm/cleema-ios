//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Styling
import SwiftUI

// MARK: - View

public struct SurveysView: View {
    let store: StoreOf<Surveys>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<Surveys>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: styleGuide.interItemSpacing) {
                    ForEachStore(
                        store.scope(state: \.surveys, action: Surveys.Action.survey)
                    ) {
                        SurveyView(store: $0)
                            .frame(maxHeight: .infinity)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, styleGuide.screenEdgePadding)
            }
        }
    }
}

// MARK: - Preview

struct SurveysView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let store = Store(initialState: .init(userAcceptedSurveys: true), reducer: Surveys())
            ZStack {
                WithViewStore(store) { viewStore in
                    SurveysView(store: store)
                        .task {
                            viewStore.send(.task)
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ScreenBackgroundView())
        }
        .cleemaStyle()
    }
}
