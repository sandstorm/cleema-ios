//
//  Created by Kumpels and Friends on 13.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension APIClient {
    @Sendable
    func avatars() async throws -> [IdentifiedImage] {
        let result: [IdentifiedImageResponse] = try await decoded(for: .avatars(.fetchList), with: token)

        return result.compactMap {
            guard let image = RemoteImage(rawValue: $0.image, baseURL: baseURL) else { return nil }

            return IdentifiedImage(id: .init($0.uuid), image: image)
        }
    }
}
