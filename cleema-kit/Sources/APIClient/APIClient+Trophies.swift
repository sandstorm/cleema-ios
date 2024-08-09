//
//  Created by Kumpels and Friends on 11.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    func trophies() async throws -> [Trophy] {
        let result: [TrophyItemResponse] = try await decoded(for: .trophies(.me), with: token)
        return result.compactMap {
            guard let image = RemoteImage(rawValue: $0.trophy.image, baseURL: baseURL) else { return nil }

            return Trophy(
                id: .init($0.trophy.uuid),
                date: $0.date,
                title: $0.trophy.title,
                image: image
            )
        }
    }

    @Sendable
    func newTrophies() async throws -> [Trophy] {
        let result: [TrophyItemResponse] = try await decoded(for: .trophies(.new), with: token)
        return result.compactMap {
            guard let image = RemoteImage(rawValue: $0.trophy.image, baseURL: baseURL) else { return nil }

            return Trophy(
                id: .init($0.trophy.uuid),
                date: $0.date,
                title: $0.trophy.title,
                image: image
            )
        }.sorted(by: { $0.date > $1.date })
    }
}
