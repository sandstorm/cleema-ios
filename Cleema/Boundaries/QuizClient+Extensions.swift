//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Dependencies
import Foundation
import QuizClientLive

extension QuizClientKey: DependencyKey {
    public static let liveValue = QuizClient.live(from: APIClient.shared)
}
