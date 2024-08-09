//
//  Created by Kumpels and Friends on 25.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import Logging
import ProjectsClientLive

extension ProjectsClientKey: DependencyKey {
    public static let liveValue = ProjectsClient.live(from: APIClient.shared, log: Logging.default)
}
