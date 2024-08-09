//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

struct QuizSaveResponse: Codable {
    var date: Date
    var answer: QuizAnswer
    var uuid: UUID
}
