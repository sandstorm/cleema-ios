//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

enum AuthRoute {
    case login(user: String, password: String)
    case register(CreateUserRequest)
    case confirmAccount(String)
}

let authRouter = OneOf {
    Route(.case(AuthRoute.login)) {
        Method.post

        Path {
            "local"
        }

        Headers { Field("content-type") { "application/x-www-form-urlencoded" } }

        Body {
            FormData {
                Field("identifier")
                Field("password")
            }
        }
    }

    Route(.case(AuthRoute.register)) {
        Method.post
        Path {
            "local"
            "register"
        }
        Headers { Field("content-type") { "application/json" } }
        Body(.json(CreateUserRequest.self))
    }

    Route(.case(AuthRoute.confirmAccount)) {
        Path { "email-confirmation" }

        Query {
            Field("confirmation") {
                CharacterSet.urlPathAllowed.map(.string)
            }
        }
    }
}
