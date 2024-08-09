//
//  Created by Kumpels and Friends on 05.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import MarkdownUI
import Models
import Styling
import SwiftUI

public struct QuizAnswering: ReducerProtocol {
    public typealias State = QuizState

    public enum Action: Equatable {
        case answerTapped(Quiz.Choice)
    }

    @Dependency(\.date.now) var now
    @Dependency(\.quizClient.saveState) var saveState
    @Dependency(\.log) var log

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .answerTapped(answer):
            let now = now
            guard
                state.answer == nil || (
                    state.answer?.date.numberOfDays(to: now) ?? Int
                        .max
                ) >= 1 else { return .none }

            let isCorrectAnswer = answer == state.quiz.correctAnswer
            if isCorrectAnswer {
                state.maxSuccessStreak += 1
                state.currentSuccessStreak += 1
            } else {
                state.currentSuccessStreak = 0
            }
            state.streak += 1
            state.answer = .init(date: now, choice: answer)
            return .fireAndForget { [quizState = state] in
                do {
                    try await saveState(quizState)
                } catch {
                    log.error("Error answering quiz", userInfo: ["quizState": quizState, "error": error])
                }
            }
        }
    }
}

// MARK: - View

public struct QuizAnsweringView: View {
    let store: StoreOf<QuizAnswering>

    public init(store: StoreOf<QuizAnswering>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                GroupBox {
                    VStack(alignment: .leading, spacing: 24) {
                        Image(decorative: "quiz", bundle: .module)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)

                        Markdown(viewStore.quiz.question)
                            .font(.montserratBold(style: .headline, size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)

                        VStack(spacing: 8) {
                            ForEach(viewStore.availableChoices) { answerID in
                                let answer = viewStore.quiz.choices[answerID]!
                                Button(action: { viewStore.send(.answerTapped(answerID), animation: .default) }) {
                                    Markdown(answer)
                                    #if DEBUG
                                        .foregroundColor(
                                            viewStore.quiz
                                                .correctAnswer == answerID ? .defaultText : .white
                                        )
                                    #endif
                                }
                                .buttonStyle(AnswerButtonStyle(
                                    answer: answerID,
                                    isHighlighted: viewStore.tappedAnswer == viewStore.quiz
                                        .correctAnswer
                                ))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .disabled(viewStore.answer != nil)
                            }
                        }

                        if viewStore.answer != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(
                                    viewStore.isAnswerCorrect ? L10n.Answer.Result.Correct.label : L10n.Answer.Result
                                        .Wrong.label
                                )
                                .font(.montserratBold(style: .headline, size: 14))
                                Markdown(viewStore.quiz.explanation)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding()
                .navigationBarTitle(L10n.Answering.title)
                .navigationBarTitleDisplayMode(.inline)
                .groupBoxStyle(AnswerGroupBoxStyle())
            }
        }
        .background(ScreenBackgroundView())
    }
}

extension QuizAnswering.State {
    var tappedAnswer: Quiz.Choice? {
        answer?.choice
    }

    var isAnswerCorrect: Bool {
        tappedAnswer == quiz.correctAnswer
    }
}

// MARK: - Preview

struct QuizAnsweringView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuizAnsweringView(
                store: .init(
                    initialState: .init(quiz: .fake(), streak: 0),
                    reducer: QuizAnswering()
                )
            )
        }
        .cleemaStyle()
    }
}
