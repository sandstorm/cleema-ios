//
//  Created by Kumpels and Friends on 25.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

enum InfoRoute {
    case about
    case privacyPolicy
    case imprint
    case partnership
    case sponsorship
}

let infoRouter = OneOf {
    Route(.case(InfoRoute.about)) {
        Path { "about" }
    }

    Route(.case(InfoRoute.privacyPolicy)) {
        Path { "privacy-policy" }
    }

    Route(.case(InfoRoute.imprint)) {
        Path { "legal-notice" }
    }

    Route(.case(InfoRoute.partnership)) {
        Path { "partnership" }
    }

    Route(.case(InfoRoute.sponsorship)) {
        Path { "sponsor-membership" }
    }
}
