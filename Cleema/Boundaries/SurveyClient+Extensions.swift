//
//  Created by Kumpels and Friends on 02.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Foundation
import SurveysClientLive

extension SurveysClientKey: DependencyKey {
    public static var liveValue: SurveysClient = .from(apiClient: APIClient.shared)
}
