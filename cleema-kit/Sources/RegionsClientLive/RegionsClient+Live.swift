//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import ComposableArchitecture
import Foundation
import Models
import RegionsClient

public extension RegionsClient {
    static func from(apiClient: APIClient) -> Self {
        .init(regions: apiClient.regions)
    }

    func cached(for seconds: TimeInterval) -> Self {
        typealias Cache = (lastUpdate: Date, regions: [Region])
        let cached: ActorIsolated<Cache?> = .init(nil)

        return .init(
            regions: { id in
                if id == nil {
                    let cache = await cached.value
                    if let cache, cache.lastUpdate + seconds > Date.now {
                        return cache.regions
                    } else {
                        let regions = try await self.regions(id)
                        await cached.setValue((Date.now, regions))
                        return regions
                    }
                } else {
                    return try await self.regions(id)
                }
            }
        )
    }
}
