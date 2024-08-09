//
//  Created by Kumpels and Friends on 23.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct ChallengeTemplateResponse: Codable {
    var title: String
    var teaserText: String?
    var description: String
    var isPublic: Bool
    var interval: Interval
    var kind: Kind
    var goalType: GoalType
    var goalSteps: Steps?
    var goalMeasurement: GoalMeasurement?
    var partner: PartnerResponse?
    var image: IdentifiedImageResponse?
}
