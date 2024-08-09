//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import CasePaths
import Foundation
import URLRouting

public enum AppRoute: Equatable {
    case invitation(String)
    case becomeSponsor
    case becomeSponsorForUserWithID(UUID)
    case emailConfirmationRequest(String)
}

// TODO: move to live client?
public let appRouter = OneOf {
    Route(.case(AppRoute.invitation)) {
        Path {
            "invites"
            CharacterSet.urlPathAllowed.map(.string)
        }
    }

    Route(.case(AppRoute.becomeSponsor)) {
        Path {
            "become-sponsor"
        }
    }

    Route(.case(AppRoute.becomeSponsorForUserWithID)) {
        Path {
            "become-sponsor"
            UUID.parser()
        }
    }

    Route(.case(AppRoute.emailConfirmationRequest)) {
        Path {
            "email-confirmation"
        }

        Query {
            Field("confirmation") {
                CharacterSet.urlPathAllowed.map(.string)
            }
        }
    }
}
