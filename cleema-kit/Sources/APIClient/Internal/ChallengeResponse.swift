//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

struct ChallengeResponse: Codable {
    struct Join: Codable {
        var answers: [Answer]
    }

    struct UserProgressResponse: Codable {
        var totalAnswers: Int
        var succeededAnswers: Int
        var user: SocialUserResponse
    }

    var uuid: UUID
    var title: String
    var teaserText: String?
    var description: String
    var isPublic: Bool
    var startDate: Date
    var endDate: Date
    var kind: Kind
    var interval: Interval
    var goalType: GoalType
    var goalSteps: Steps?
    var goalMeasurement: GoalMeasurement?
    var region: RegionResponse
    var joined: Bool
    var joinedChallenge: Join?
    var partner: PartnerResponse?
    var userProgress: [UserProgressResponse]?
    var usersJoined: [SocialUserResponse]?
    var image: IdentifiedImageResponse?
    var collectiveGoalAmount: Int?
    var collectiveProgress: Int?
}

extension ChallengeResponse.Join {
    func domainAnswers(for startDate: Date) -> [Int: JoinedChallenge.Answer] {
        guard !answers.isEmpty else { return [:] }

        return answers.reduce(into: [Int: JoinedChallenge.Answer]()) { acc, answer in
            acc[answer.dayIndex] = answer.answer == .succeeded ? .succeeded : .failed
        }
    }
}
