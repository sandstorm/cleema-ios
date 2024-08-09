//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum QuizRoute {
    case fetch(regionId: UUID? = nil)
    case save(APIRequest<QuizAnswerRequest>)
}

let quizRouter = OneOf {
    Route(.case(QuizRoute.fetch)) {
        Method.get
        Path {
            "quizzes"
            "current"
        }
        
        Query {
            Optionally { Field("filters[$or][1][region][uuid][$eq]", default: nil) { UUID.parser() } }
        }
    }

    Route(.case(QuizRoute.save)) {
        Method.post
        Path { "quiz-responses" }
        Headers { Field("Content-Type") { "application/json" } }
        Body(.json(APIRequest<QuizAnswerRequest>.self))
    }
}
