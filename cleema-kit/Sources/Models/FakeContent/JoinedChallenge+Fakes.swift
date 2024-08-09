//
//  Created by Kumpels and Friends on 31.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

public extension JoinedChallenge {
    static func fake(challenge: Challenge = .fake(), answers: [Int: JoinedChallenge.Answer] = [:]) -> Self {
        .init(challenge: challenge, answers: answers)
    }
}
