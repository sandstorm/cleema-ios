//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import MarkdownUI
import Styling
import SwiftUI

struct QuestionView: View {
    let store: StoreOf<QuizFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let quizState = viewStore.quizState {
                VStack(alignment: .trailing) {
                    Markdown(quizState.quiz.question)
                        .font(.montserrat(style: .body, size: 14).leading(.loose))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onOpenMarkdownLink()

                    NavigationLink(
                        destination: IfLetStore(
                            self.store.scope(
                                state: \.quizAnswering,
                                action: QuizFeature.Action.quizAnswer
                            ),
                            then: QuizAnsweringView.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: \.showsAnswers,
                            send: QuizFeature.Action.setNavigation(isActive:)
                        )
                    ) {
                        Text(L10n.Answer.Button.Action.label)
                    }
                    .buttonStyle(.action)
                }
            }
        }
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        GroupBox {
            QuestionView(
                store: Store(
                    initialState: .init(quizState: .init(quiz: .fake(), streak: 0)),
                    reducer: QuizFeature()
                )
            )
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(ScreenBackgroundView())
        .groupBoxStyle(.largeWave)
        .cleemaStyle()
    }
}
