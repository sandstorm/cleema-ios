//
//  Created by Kumpels and Friends on 02.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct SurveyResponse: Codable {
    var uuid: UUID
    var title: String
    var description: String
    var finished: Bool
    var surveyUrl: URL?
    var evaluationUrl: URL?
}
