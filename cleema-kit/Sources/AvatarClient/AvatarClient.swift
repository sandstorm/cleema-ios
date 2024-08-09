//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

public struct AvatarClient {
    public var loadAvatars: @Sendable () async throws -> [IdentifiedImage]

    public init(loadAvatars: @Sendable @escaping () async throws -> [IdentifiedImage]) {
        self.loadAvatars = loadAvatars
    }
}

public enum AvatarClientKey: TestDependencyKey {
    public static let previewValue = AvatarClient.preview
    public static let testValue = AvatarClient.unimplemented
}

public extension DependencyValues {
    var avatarClient: AvatarClient {
        get { self[AvatarClientKey.self] }
        set { self[AvatarClientKey.self] = newValue }
    }
}

public extension AvatarClient {
    static let unimplemented: Self = .init(
        loadAvatars: XCTestDynamicOverlay.unimplemented("\(Self.self).loadAvatars")
    )

    static let preview: Self = .init(
        loadAvatars: {
            [
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312)),
                .fake(image: .fake(width: 312, height: 312))
            ]
        }
    )
}
