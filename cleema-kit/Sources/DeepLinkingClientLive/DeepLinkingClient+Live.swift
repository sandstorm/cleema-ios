//
//  Created by Kumpels and Friends on 29.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import DeepLinking
import Foundation

struct DeepLinkingError: Error {}

public extension DeepLinkingClient {
    static func live(baseURL: URL, apiURL: URL) -> Self {
        .init { route in
            appRouter
                .baseURL(baseURL.absoluteString)
                .url(for: route)
        } routeForURL: { url in
            let urlString: String? = {
                if url.absoluteString.hasPrefix(baseURL.absoluteString) {
                    return url.absoluteString.deletingPrefix(baseURL.absoluteString)
                } else if url.absoluteString.hasPrefix(apiURL.absoluteString) {
                    return url.absoluteString.deletingPrefix(apiURL.absoluteString)
                } else {
                    return nil
                }
            }()
            guard let urlString, let relativeURL = URL(string: urlString) else { throw DeepLinkingError() }
            return try appRouter.match(url: relativeURL)
        }
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
}
