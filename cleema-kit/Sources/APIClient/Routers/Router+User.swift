//
//  Created by Kumpels and Friends on 15.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum UserRoute {
    case me
    case follows
    case followInvitation(String)
    case unfollow(UUID)
    case delete(UUID)
    case update(UUID, UpdateUserRequest)
}

let userRouter = OneOf {
    Route(.case(UserRoute.me)) {
        Path { "me" }

        Query {
            Field("populate") { "*" }
        }
    }

    Route(.case(UserRoute.follows)) {
        Path { "me" }
        Path { "follows" }
    }

    Route(.case(UserRoute.unfollow)) {
        Method.delete

        Path { "me" }
        Path { "follows" }
        Path { UUID.parser() }
    }

    Route(.case(UserRoute.followInvitation)) {
        Method.post

        Path { "me" }
        Path { "follows" }

        Body {
            FormData {
                Field("ref")
            }
        }
    }

    Route(.case(UserRoute.delete)) {
        Method.delete

        Path { UUID.parser() }
    }

    Route(.case(UserRoute.update)) {
        Method.patch

        Path { UUID.parser() }
        Headers { Field("Content-Type") { "application/json" } }
        Body(.json(UpdateUserRequest.self))
    }
}
