//
//  Created by Kumpels and Friends on 30.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct UserProgress: Hashable, Identifiable {
    public var totalAnswers: Int
    public var succeededAnswers: Int
    public var user: SocialUser

    public init(totalAnswers: Int, succeededAnswers: Int, user: SocialUser) {
        self.totalAnswers = totalAnswers
        self.succeededAnswers = succeededAnswers
        self.user = user
    }

    public var id: User.ID { user.id }
}
