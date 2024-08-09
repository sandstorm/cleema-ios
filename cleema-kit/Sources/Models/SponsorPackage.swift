//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public enum SponsorPackage: CaseIterable, Identifiable {
    public typealias ID = Tagged<SponsorPackage, String>

    case fan
    case maker
    case love

    public var id: ID {
        switch self {
        case .fan:
            return "fan"
        case .maker:
            return "macher"
        case .love:
            return "liebe"
        }
    }
}
