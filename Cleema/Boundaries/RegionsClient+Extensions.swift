//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import RegionsClientLive

extension RegionsClientKey: DependencyKey {
    public static let liveValue: RegionsClient = .from(apiClient: APIClient.shared).cached(for: 60 * 60)
}
