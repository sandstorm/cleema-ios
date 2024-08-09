//
//  Created by Kumpels and Friends on 07.09.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

extension DependencyValues {
    public var challengeID: ChallengeIDGenerator {
        get { self[ChallengeIDGeneratorKey.self] }
        set { self[ChallengeIDGeneratorKey.self] = newValue }
    }

    private enum ChallengeIDGeneratorKey: DependencyKey {
        static let liveValue: ChallengeIDGenerator = .live
        static let testValue: ChallengeIDGenerator = .unimplemented
    }
}

public struct ChallengeIDGenerator: Sendable {
    private let generate: @Sendable () -> Challenge.ID

    public static func constant(_ id: Challenge.ID) -> Self {
        Self { id }
    }

    public static let preview = live
    public static let live = Self { Challenge.ID(rawValue: .init()) }

    /// A generator that calls `XCTFail` when it is invoked.
    public static let unimplemented: Self = .init(
        generate: XCTestDynamicOverlay
            .unimplemented("\(Self.self).generate", placeholder: Challenge.ID(rawValue: .init()))
    )

    public func callAsFunction() -> Challenge.ID {
        generate()
    }
}
