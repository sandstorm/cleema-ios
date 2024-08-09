//
//  Created by Kumpels and Friends on 17.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

enum SingleNewsRoute {
    case fav
    case unfav
    case markAsRead
}

enum NewsRoute {
    case search(String? = nil, regionId: UUID? = nil)
    case tags
    case singleNews(UUID, SingleNewsRoute)
    case faved
}

let singleNewsRouter = OneOf {
    Route(.case(SingleNewsRoute.fav)) {
        Method.patch
        Path { "fav" }
    }

    Route(.case(SingleNewsRoute.unfav)) {
        Method.patch
        Path { "unfav" }
    }

    Route(.case(SingleNewsRoute.markAsRead)) {
        Method.patch
        Path { "read" }
    }
}

let newsRouter = OneOf {
    Route(.case(NewsRoute.search)) {
        Path { "news-entries" }

        Query {
            Field("populate") { "tags" }
            Field("populate") { "image" }
            Optionally { Field("filters[$and][0][tags][value][$containsi]", default: nil) { wordsParser } }
            Optionally { Field("filters[$or][1][region][uuid][$eq]", default: nil) { UUID.parser() } }
            Field("filters[$or][2][type][$eq]", default: nil) { "tip" }
        }
    }

    Route(.case(NewsRoute.tags)) {
        Path { "news-tags" }
    }

    Route(.case(NewsRoute.singleNews)) {
        Path { "news-entries" }
        Path { UUID.parser() }
        singleNewsRouter
    }

    Route(.case(NewsRoute.faved)) {
        Path { "news-entries" }

        Query {
            Field("isFaved") { "true" }
            Field("populate") { "*" }
        }
    }
}
