//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

enum CleemaRoute {
    case authentication(AuthRoute)
    case news(NewsRoute)
    case challenges(ChallengesRoute)
    case challengeTemplates
    case regions(RegionsRoute)
    case projects(ProjectsRoute)
    case quiz(QuizRoute)
    case info(InfoRoute)
    case user(UserRoute)
    case marketplace(MarketplaceRoute)
    case trophies(TrophiesRoute)
    case surveys(SurveysRoute)
    case avatars(AvatarsRoute)
    case sponsorship(SponsorshipRoute)
}

let apiRouter = OneOf {
    Route(.case(CleemaRoute.news)) {
        Path { "api" }
        newsRouter
    }

    Route(.case(CleemaRoute.challenges)) {
        Path {
            "api"
            "challenges"
        }

        challengesRouter
    }

    Route(.case(CleemaRoute.challengeTemplates)) {
        Path {
            "api"
            "challenge-templates"
        }
        Query {
            Field("populate") { "deep" }
        }
    }

    Route(.case(CleemaRoute.authentication)) {
        Path {
            "api"
            "auth"
        }

        authRouter
    }

    Route(.case(CleemaRoute.regions)) {
        Path { "api" }
        regionsRouter
    }

    Route(.case(CleemaRoute.projects)) {
        Path { "api"
            "projects"
        }
        projectsRouter
    }

    Route(.case(CleemaRoute.quiz)) {
        Path { "api" }
        quizRouter
    }

    Route(.case(CleemaRoute.info)) {
        Path { "api" }
        infoRouter
    }

    Route(.case(CleemaRoute.user)) {
        Path {
            "api"
            "users"
        }
        userRouter
    }

    Route(.case(CleemaRoute.marketplace)) {
        Path {
            "api"
            "offers"
        }
        marketplaceRouter
    }

    Route(.case(CleemaRoute.trophies)) {
        Path {
            "api"
            "trophies"
            "me"
        }
        trophiesRouter
    }

    Route(.case(CleemaRoute.surveys)) {
        Path {
            "api"
            "surveys"
        }
        surveysRouter
    }

    Route(.case(CleemaRoute.avatars)) {
        Path { "api" }
        avatarsRouter
    }

    Route(.case(CleemaRoute.sponsorship)) {
        Path { "api" }
        sponsorshipRouter
    }
}

let wordsParser = Consumed {
    Many(1...) {
        Prefix(1...) { $0.isLetter || $0.isNumber }
    } separator: {
        Whitespace(1..., .horizontal)
    }
}.map(.string)
