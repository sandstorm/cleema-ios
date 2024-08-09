//
//  Created by Kumpels and Friends on 28.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import DeepLinkingClientLive
import Foundation

extension DeepLinkingClientKey: DependencyKey {
    public static let liveValue = DeepLinkingClient.live(baseURL: .cleemaBaseURL, apiURL: .cleemaAPIBaseURL)
}
