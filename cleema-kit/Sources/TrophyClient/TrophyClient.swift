//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models

public struct TrophyClient {
    public var loadTrophies: @Sendable () async throws -> [Trophy]
    public var newTrophies: @Sendable () async throws -> [Trophy]

    public init(
        loadTrophies: @Sendable @escaping () async throws -> [Trophy],
        newTrophies: @Sendable @escaping () async throws -> [Trophy]
    ) {
        self.loadTrophies = loadTrophies
        self.newTrophies = newTrophies
    }
}

public enum TrophyClientKey: TestDependencyKey {
    public static let testValue = TrophyClient.unimplemented
}

public extension DependencyValues {
    var trophyClient: TrophyClient {
        get { self[TrophyClientKey.self] }
        set { self[TrophyClientKey.self] = newValue }
    }
}

import XCTestDynamicOverlay

extension TrophyClient {
    static let unimplemented: Self = .init(
        loadTrophies: XCTestDynamicOverlay
            .unimplemented("\(Self.self).loadTrophies", placeholder: []),
        newTrophies: XCTestDynamicOverlay
            .unimplemented("\(Self.self).newTrophies", placeholder: [])
    )

    static let preview: Self = .init(
        loadTrophies: {
            [
                .fake(),
                .fake()
            ]
        },
        newTrophies: {
            [
                .fake()
            ]
        }
    )
}
