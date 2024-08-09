//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models

public struct SurveysClient {
    public var surveys: @Sendable () async throws -> [Survey]

    public var participate: @Sendable (Survey.ID) async throws -> Survey

    public var evaluate: @Sendable (Survey.ID) async throws -> Survey

    public init(
        surveys: @Sendable @escaping () async throws -> [Survey],
        participate: @Sendable @escaping (Survey.ID) async throws -> Survey,
        evaluate: @Sendable @escaping (Survey.ID) async throws -> Survey
    ) {
        self.surveys = surveys
        self.participate = participate
        self.evaluate = evaluate
    }
}

public enum SurveysClientKey: TestDependencyKey {
    public static let previewValue = SurveysClient.preview
    public static let testValue = SurveysClient.unimplemented
}

public extension DependencyValues {
    var surveysClient: SurveysClient {
        get { self[SurveysClientKey.self] }
        set { self[SurveysClientKey.self] = newValue }
    }
}

import XCTestDynamicOverlay

public extension SurveysClient {
    static let unimplemented: Self = .init(
        surveys: XCTestDynamicOverlay.unimplemented("\(Self.self).surveys", placeholder: []),
        participate: XCTestDynamicOverlay.unimplemented("\(Self.self).participate", placeholder: .fake()),
        evaluate: XCTestDynamicOverlay.unimplemented("\(Self.self).evaluate", placeholder: .fake())
    )
}

public extension SurveysClient {
    static let preview: Self = .init(
        surveys: {
            [.fake(state: .evaluation(URL(string: "https://cleema.app")!)), .fake()]
        },
        participate: { _ in
            .fake()
        },
        evaluate: { _ in
            .fake()
        }
    )
}
