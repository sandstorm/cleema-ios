//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

enum ChallengeRoute {
    case fetch
    case join
    case leave
    case answer(AnswerRequest)
}

enum ChallengesRoute {
    case region(UUID? = nil)
    case joined
    case challenge(UUID, ChallengeRoute = .fetch)
    case create(APIRequest<CreateChallengeRequest>)
}

let challengeRouter = OneOf {
    Route(.case(ChallengeRoute.fetch)) {
        Query {
            Field("populate") { "*" }
        }
    }

    Route(.case(ChallengeRoute.join)) {
        Method.patch
        Path { "join" }
    }

    Route(.case(ChallengeRoute.leave)) {
        Method.patch
        Path { "leave" }
    }

    Route(.case(ChallengeRoute.answer)) {
        Method.patch
        Path { "answer" }
        Headers { Field("Content-Type") { "application/json" } }
        Body(.json(AnswerRequest.self))
    }
}

let challengesRouter = OneOf {
    Route(.case(ChallengesRoute.region)) {
        Query {
            Field("populate") { "*" }
            Optionally { Field("filters[region][uuid][$eq]", default: nil) { UUID.parser() } }
            Field("filters[kind][$in]") { "partner,collective" }
        }
    }

    Route(.case(ChallengesRoute.joined)) {
        Query {
            Field("populate") { "*" }
            Field("joined") { "true" }
        }
    }

    Route(.case(ChallengesRoute.challenge)) {
        Path { UUID.parser() }
        challengeRouter
    }

    Route(.case(ChallengesRoute.create)) {
        Method.post
        Headers { Field("Content-Type") { "application/json" } }
        Body(.json(APIRequest<CreateChallengeRequest>.self, encoder: .plainDate))
    }
}
