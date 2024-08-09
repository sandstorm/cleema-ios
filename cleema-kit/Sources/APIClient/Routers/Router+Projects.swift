//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum ProjectRoute {
    case fetch
    case join
    case leave
    case fav
    case unfav
}

enum ProjectsRoute {
    case region(UUID? = nil, Bool? = nil)
    case project(UUID, ProjectRoute)
}

let projectRouter = OneOf {
    Route(.case(ProjectRoute.fetch)) {
        Query {
            Field("populate") { "*" }
        }
    }

    Route(.case(ProjectRoute.join)) {
        Method.patch
        Path { "join" }
    }

    Route(.case(ProjectRoute.leave)) {
        Method.patch
        Path { "leave" }
    }

    Route(.case(ProjectRoute.fav)) {
        Method.patch
        Path { "fav" }
    }

    Route(.case(ProjectRoute.unfav)) {
        Method.patch
        Path { "unfav" }
    }
}

let projectsRouter = OneOf {
    Route(.case(ProjectsRoute.region)) {
        Query {
            Field("populate") { "*" }
            Optionally { Field("filters[region][uuid][$eq]", default: nil) { UUID.parser() } }
            Optionally { Field("isFaved", default: nil) { Bool.parser() } }
        }
    }

    Route(.case(ProjectsRoute.project)) {
        Path { UUID.parser() }

        projectRouter
    }
}
