//
//  Created by Kumpels and Friends on 21.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Boundaries
import Foundation
import UserClientLive

extension UserDefaults {
    func executeLaunchArguments() {
        if bool(forKey: DefaultKeys.wipeUser.rawValue) {
            UserClient.removeUser()
        }
    }
}
