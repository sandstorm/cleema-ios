//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import Models
import SurveysClient

public extension SurveysClient {
    static func from(apiClient: APIClient) -> Self {
        .init(
            surveys: { try await apiClient.surveys() },
            participate: { try await apiClient.participateSurvey(id: $0) },
            evaluate: { try await apiClient.evaluateSurvey(id: $0) }
        )
    }
}
