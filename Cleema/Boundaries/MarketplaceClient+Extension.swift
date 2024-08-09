//
//  Created by Kumpels and Friends on 26.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import MarketplaceClientLive

extension MarketplaceClientKey: DependencyKey {
    public static var liveValue: MarketplaceClient = .from(APIClient.shared, userDefaults: .standard)
}
