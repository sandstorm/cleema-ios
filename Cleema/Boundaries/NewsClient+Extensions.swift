//
//  Created by Kumpels and Friends on 19.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import Logging
import NewsClientLive

extension NewsClientKey: DependencyKey {
    public static var liveValue: NewsClient = .from(APIClient.shared, log: .default)
}
