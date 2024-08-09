//
//  Created by Kumpels and Friends on 19.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models

public struct RegionsClient {
    public var regions: @Sendable (Region.ID?) async throws -> [Region]

    public init(regions: @escaping @Sendable (Region.ID?) async throws -> [Region]) {
        self.regions = regions
    }
}

public enum RegionsClientKey: TestDependencyKey {
    public static let previewValue = RegionsClient.preview
    public static let testValue = RegionsClient.unimplemented
}

public extension DependencyValues {
    var regionsClient: RegionsClient {
        get { self[RegionsClientKey.self] }
        set { self[RegionsClientKey.self] = newValue }
    }
}

import XCTestDynamicOverlay

public extension RegionsClient {
    static let unimplemented: Self = .init(regions: XCTUnimplemented("\(Self.self).regions", placeholder: []))
}

public extension RegionsClient {
    static let preview: Self = .init(regions: { id in
        try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 5)
        guard let id else {
            return [Region.leipzig, .dresden, .pirna]
        }
        return [Region.leipzig, .dresden, .pirna].filter { $0.id == id }
    })
}
