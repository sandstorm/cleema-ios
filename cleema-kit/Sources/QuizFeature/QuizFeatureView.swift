//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import Styling
import SwiftUI

// MARK: - View

extension Quiz.Choice {
    var index: String {
        switch self {
        case .a:
            return "A"
        case .b:
            return "B"
        case .c:
            return "C"
        case .d:
            return "D"
        }
    }
}

public struct QuizFeatureView: View {
    let store: StoreOf<QuizFeature>

    @Environment(\.styleGuide) var styleGuide

    public init(store: StoreOf<QuizFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            GroupBox {
                switch viewStore.quizState?.answerState {
                case .none:
                    Color.clear
                        .frame(height: 40)
                case .pending:
                    QuestionView(store: store)
                case .answered:
                    AnswerResultView(
                        title: L10n.Answer.Result.Title.label,
                        message: L10n.Answer.Result.Message.label
                    )
                }
            } label: {
                HStack {
                    Text(L10n.Answering.title)

                    Spacer()
                    if viewStore.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, styleGuide.screenEdgePadding)
            .onAppear {
                viewStore.send(.load)
            }
        }
        .groupBoxStyle(.largeWave)
        .cardShadow()
    }
}

struct QuizFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuizFeatureView(
                store: Store(
                    initialState: .init(),
                    reducer: QuizFeature()
                )
            )
            .frame(maxHeight: .infinity)
            .background(ScreenBackgroundView())
        }
        .cleemaStyle()
    }
}
