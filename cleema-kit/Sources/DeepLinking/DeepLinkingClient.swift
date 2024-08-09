//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation

public struct DeepLinkingClient {
    public var urlForRoute: (_ route: AppRoute) -> URL
    public var routeForURL: (URL) throws -> AppRoute

    public init(
        urlForRoute: @escaping (_ code: AppRoute) -> URL,
        routeForURL: @escaping (URL) throws -> AppRoute
    ) {
        self.urlForRoute = urlForRoute
        self.routeForURL = routeForURL
    }
}

public enum DeepLinkingClientKey: TestDependencyKey {
    public static let testValue = DeepLinkingClient.unimplemented
    public static let previewValue = DeepLinkingClient(urlForRoute: { _ in
        URL(string: "https://localhost/invites/1234")!
    }, routeForURL: { _ in AppRoute.invitation("1234") })
}

public extension DependencyValues {
    var deepLinkingClient: DeepLinkingClient {
        get { self[DeepLinkingClientKey.self] }
        set { self[DeepLinkingClientKey.self] = newValue }
    }
}

import XCTestDynamicOverlay

extension DeepLinkingClient {
    static let unimplemented: Self = .init(
        urlForRoute: XCTestDynamicOverlay.unimplemented(
            "\(Self.self).urlForRoute",
            placeholder: URL(string: "https://localhost")!
        ),
        routeForURL: XCTestDynamicOverlay.unimplemented(
            "\(Self.self).routeForURL",
            placeholder: .invitation("unimplemented")
        )
    )
}
