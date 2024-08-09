//
//  Created by Kumpels and Friends on 22.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    func quizState(regionID: Region.ID?) async throws -> QuizState {
        let result: QuizResponse = try await decoded(
            for: .quiz(.fetch(regionId: regionID?.rawValue)),
            with: token
        )
        guard let state = QuizState(rawValue: result, log) else {
            throw InvalidResponse()
        }

        return state
    }

    @Sendable
    func save(state: QuizState) async throws {
        guard let answer = state.answer,
              let given = QuizAnswer(rawValue: answer.choice.rawValue)
        else {
            throw InvalidRequest()
        }
        let data = QuizAnswerRequest(quiz: state.quiz.id.rawValue, answer: given)
        let _: QuizSaveResponse = try await decoded(for: .quiz(.save(APIRequest(data: data))), with: token)
    }
}
