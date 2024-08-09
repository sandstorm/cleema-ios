//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public struct BecomeSponsorClient {
    public var addMembership: @Sendable (SponsorPackage.ID, SponsorData) async throws -> Void

    public init(addMembership: @escaping @Sendable (SponsorPackage.ID, SponsorData) async throws -> Void) {
        self.addMembership = addMembership
    }
}

import Dependencies
import XCTestDynamicOverlay

public enum BecomeSponsorClientKey: TestDependencyKey {
    public static let testValue = BecomeSponsorClient.unimplemented
    public static let previewValue = BecomeSponsorClient.preview
}

public extension DependencyValues {
    var becomeSponsorClient: BecomeSponsorClient {
        get { self[BecomeSponsorClientKey.self] }
        set { self[BecomeSponsorClientKey.self] = newValue }
    }
}

public extension BecomeSponsorClient {
    static let unimplemented: Self = .init(
        addMembership: XCTestDynamicOverlay.unimplemented("\(Self.self).addMembership")
    )

    static let preview: Self = .init(
        addMembership: { _, _ in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
        }
    )
}
