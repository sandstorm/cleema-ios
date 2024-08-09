//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    func surveys() async throws -> [Survey] {
        let response: [SurveyResponse] = try await decoded(for: .surveys(.fetch), with: token)

        return response.compactMap(Survey.init(rawValue:))
    }

    @Sendable
    func participateSurvey(id: Survey.ID) async throws -> Survey {
        let response: SurveyResponse = try await decoded(for: .surveys(.participate(id.rawValue)), with: token)
        guard let survey = Survey(rawValue: response)
        else { throw InvalidResponse("SurveyResponse not convertible to Survey.") }
        return survey
    }

    @Sendable
    func evaluateSurvey(id: Survey.ID) async throws -> Survey {
        let response: SurveyResponse = try await decoded(for: .surveys(.evaluate(id.rawValue)), with: token)
        guard let survey = Survey(rawValue: response)
        else { throw InvalidResponse("SurveyResponse not convertible to Survey.") }
        return survey
    }
}
