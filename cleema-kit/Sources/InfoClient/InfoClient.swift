//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

public struct InfoClient {
    public var loadAbout: @Sendable () async throws -> InfoContent
    public var loadPrivacy: @Sendable () async throws -> InfoContent
    public var loadImprint: @Sendable () async throws -> InfoContent
    public var loadPartnership: @Sendable () async throws -> InfoContent
    public var loadSponsorship: @Sendable () async throws -> InfoContent

    public init(
        loadAbout: @escaping @Sendable () async throws -> InfoContent,
        loadPrivacy: @escaping @Sendable () async throws -> InfoContent,
        loadImprint: @escaping @Sendable () async throws -> InfoContent,
        loadPartnership: @escaping @Sendable () async throws -> InfoContent,
        loadSponsorship: @escaping @Sendable () async throws -> InfoContent
    ) {
        self.loadAbout = loadAbout
        self.loadPrivacy = loadPrivacy
        self.loadImprint = loadImprint
        self.loadPartnership = loadPartnership
        self.loadSponsorship = loadSponsorship
    }
}

public extension InfoClient {
    static let preview: Self = .init(
        loadAbout: {
            .init(text: "About...")
        }, loadPrivacy: {
            .init(text: "Privacy...")
        }, loadImprint: {
            .init(text: "Imprint...")
        }, loadPartnership: {
            .init(text: "Partnership...")
        }, loadSponsorship: {
            .init(text: "Sponsorship...")
        }
    )
}

public extension InfoClient {
    static let unimplemented: Self = InfoClient(
        loadAbout: XCTestDynamicOverlay.unimplemented("loadAbout"),
        loadPrivacy: XCTestDynamicOverlay.unimplemented("loadPrivacy"),
        loadImprint: XCTestDynamicOverlay.unimplemented("loadImprint"),
        loadPartnership: XCTestDynamicOverlay.unimplemented("loadPartnership"),
        loadSponsorship: XCTestDynamicOverlay.unimplemented("loadSponsorship")
    )
}

public enum InfoClientKey: TestDependencyKey {
    public static let testValue = InfoClient.unimplemented
    public static var previewValue = InfoClient.preview
}

public extension DependencyValues {
    var infoClient: InfoClient {
        get { self[InfoClientKey.self] }
        set { self[InfoClientKey.self] = newValue }
    }
}
