//
//  Created by Kumpels and Friends on 30.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Contacts
import Foundation
import Logging
import Models

extension Challenge {
    init?(rawValue: ChallengeResponse, baseURL: URL) {
        guard
            let kind = Challenge.Kind(rawValue: rawValue, baseURL: baseURL),
            let goal = Challenge.GoalType(rawValue: rawValue)
        else { return nil }
        let sponsor: Partner?
        if let rawSponsor = rawValue.partner {
            sponsor = .init(rawValue: rawSponsor, baseURL: baseURL)
        } else {
            sponsor = nil
        }
        self.init(
            id: .init(rawValue: rawValue.uuid),
            title: rawValue.title,
            teaserText: rawValue.teaserText ?? "",
            description: rawValue.description,
            type: goal,
            interval: .init(rawValue: rawValue.interval),
            startDate: rawValue.startDate,
            endDate: rawValue.endDate,
            isPublic: rawValue.isPublic,
            kind: kind,
            region: .init(rawValue: rawValue.region),
            isJoined: rawValue.joined,
            sponsor: sponsor,
            numberOfUsersJoined: rawValue.usersJoined?.count ?? 0,
            image: .init(rawValue: rawValue.image, baseURL: baseURL),
            collectiveGoalAmount: rawValue.collectiveGoalAmount,
            collectiveProgress: rawValue.collectiveProgress
        )
    }

    init?(rawValue: ChallengeTemplateResponse, baseURL: URL) {
        guard
            let kind = Challenge.Kind(rawValue: rawValue),
            let goal = Challenge.GoalType(rawValue: rawValue)
        else { return nil }
        let sponsor: Partner?
        if
            let rawSponsor = rawValue.partner
        {
            sponsor = .init(rawValue: rawSponsor, baseURL: baseURL)
        } else {
            sponsor = nil
        }
        self.init(
            id: .init(.init()),
            title: rawValue.title,
            teaserText: rawValue.teaserText ?? "",
            description: rawValue.description,
            type: goal,
            interval: .init(rawValue: rawValue.interval),
            isPublic: rawValue.isPublic,
            kind: kind,
            isJoined: false,
            sponsor: sponsor,
            image: .init(rawValue: rawValue.image, baseURL: baseURL)
        )
    }
}

extension IdentifiedImage {
    init?(rawValue: IdentifiedImageResponse?, baseURL: URL) {
        guard let rawValue, let image = RemoteImage(rawValue: rawValue.image, baseURL: baseURL) else { return nil }
        self.init(id: .init(rawValue.uuid), image: image)
    }
}

extension Challenge.Interval {
    init(rawValue: Interval) {
        switch rawValue {
        case .daily: self = .daily
        case .weekly: self = .weekly
        }
    }
}

extension Challenge.Kind {
    init?(rawValue: ChallengeResponse, baseURL: URL) {
        switch rawValue.kind {
        case .user:
            self = .user
        case .partner:
            guard let partner = rawValue.partner else { return nil }
            self = .partner(.init(rawValue: partner, baseURL: baseURL))
        case .group:
            self = .group(rawValue.userProgress?.map {
                UserProgress(
                    totalAnswers: $0.totalAnswers,
                    succeededAnswers: $0.succeededAnswers,
                    user: SocialUser(rawValue: $0.user, baseURL: baseURL)
                )
            } ?? [])
        case .collective:
            guard let partner = rawValue.partner else { return nil }
            self = .collective(.init(rawValue: partner, baseURL: baseURL))
        }
    }
}

extension Challenge.Kind {
    init?(rawValue: ChallengeTemplateResponse) {
        switch rawValue.kind {
        case .user:
            self = .user
        case .group:
            self = .group([])
        case .partner:
            // TODO: it is not possible to create partner challenges from templates? -> No, it is not.
            return nil
        case .collective:
            return nil
        }
    }
}

extension Challenge.GoalType {
    init?(rawValue: ChallengeResponse) {
        switch rawValue.goalType {
        case .steps:
            guard let steps = rawValue.goalSteps else { return nil }
            self = .steps(steps.count)
        case .measurement:
            guard let measurement = rawValue.goalMeasurement else { return nil }
            self = .measurement(measurement.value, .init(rawValue: measurement.unit))
        }
    }
}

extension Challenge.GoalType {
    init?(rawValue: ChallengeTemplateResponse) {
        switch rawValue.goalType {
        case .steps:
            guard let steps = rawValue.goalSteps else { self = .steps(1)
                return
            }
            self = .steps(steps.count)
        case .measurement:
            guard let measurement = rawValue.goalMeasurement else { self = .measurement(1, .kilograms)
                return
            }
            self = .measurement(measurement.value, .init(rawValue: measurement.unit))
        }
    }
}

extension Partner {
    init(rawValue: PartnerResponse, baseURL: URL) {
        self.init(
            id: .init(rawValue: rawValue.uuid),
            title: rawValue.title,
            url: rawValue.url,
            description: rawValue.description,
            logo: .init(rawValue: rawValue.logo, baseURL: baseURL)
        )
    }
}

extension Models.Unit {
    init(rawValue: GoalMeasurement.Unit) {
        switch rawValue {
        case .kg:
            self = .kilograms
        case .km:
            self = .kilometers
        }
    }
}

extension Region {
    init(rawValue: RegionResponse) {
        self.init(id: .init(rawValue: rawValue.uuid), name: rawValue.name)
    }
}

extension JoinedChallenge {
    init?(rawValue: ChallengeResponse, baseURL: URL) {
        guard
            let challenge = Challenge(rawValue: rawValue, baseURL: baseURL),
            let answers = rawValue.joinedChallenge?.domainAnswers(for: rawValue.startDate),
            answers.count <= challenge.duration.unitValueCount
        else { return nil }
        self.init(challenge: challenge, answers: answers)
    }
}

extension Quiz {
    init?(rawValue: QuizResponse, _ log: Logging?) {
        guard let correctChoice = Quiz.Choice(rawValue: rawValue.correctAnswer.rawValue) else {
            log?.error("Could extract correct choice from response", userInfo: ["response": rawValue])
            return nil
        }
        self.init(
            id: .init(rawValue.uuid),
            question: rawValue.question,
            choices: rawValue.answers.reduce(into: [Quiz.Choice: String]()) {
                if let choice = Quiz.Choice(rawValue: $1.option.rawValue) {
                    $0[choice] = $1.text
                }
            },
            correctAnswer: correctChoice,
            explanation: rawValue.explanation ?? ""
        )
    }
}

extension QuizState.Answer {
    init?(rawValue: QuizResponse) {
        guard
            let givenAnswer = rawValue.response,
            let choice = Quiz.Choice(rawValue: givenAnswer.answer.rawValue)
        else {
            return nil
        }
        self.init(date: givenAnswer.date, choice: choice)
    }
}

extension QuizState {
    init?(rawValue: QuizResponse, _ log: Logging?) {
        guard let quiz = Quiz(rawValue: rawValue, log) else { return nil }

        self.init(
            quiz: quiz,
            streak: rawValue.streak?.participationStreak ?? 0,
            answer: QuizState.Answer(rawValue: rawValue),
            maxSuccessStreak: rawValue.streak?.maxCorrectAnswerStreak ?? 0,
            currentSuccessStreak: rawValue.streak?.correctAnswerStreak ?? 0
        )
    }
}

extension User {
    init?(rawValue: UserResponse, password: String, baseURL: URL) {
        guard
            let rawRegion = rawValue.region,
            let avatarImage = RemoteImage(rawValue: rawValue.avatar.image, baseURL: baseURL)
        else { return nil }
        self.init(
            id: .init(rawValue.uuid),
            name: rawValue.username,
            region: .init(rawValue: rawRegion),
            joinDate: rawValue.createdAt,
            kind: .remote(password: password, email: rawValue.email),
            followerCount: rawValue.follows?.followers ?? 0,
            followingCount: rawValue.follows?.following ?? 0,
            acceptsSurveys: rawValue.acceptsSurveys,
            referralCode: rawValue.referralCode,
            avatar: .init(id: .init(rawValue.avatar.uuid), image: avatarImage),
            isSupporter: rawValue.isSupporter ?? false
        )
    }
}

extension UpdateUserRequest {
    init(user: EditUser) {
        username = user.username
        password = user.password
        passwordRepeat = user.password
        email = user.email
        acceptsSurveys = user.acceptsSurveys

        region = .init(uuid: user.region?.id.rawValue)
        avatar = .init(uuid: user.avatar?.id.rawValue)
    }
}

extension IDRequest {
    init?(uuid: UUID?) {
        guard let id = uuid else { return nil }
        self.uuid = id
    }
}

extension SocialGraph {
    init(rawValue: SocialGraphResponse, baseURL: URL) {
        self.init(
            followers: rawValue.followers.filter { !$0.isRequest }
                .map { SocialGraphItem(rawValue: $0, baseURL: baseURL) },
            following: rawValue.following.filter { !$0.isRequest }
                .map { SocialGraphItem(rawValue: $0, baseURL: baseURL) }
        )
    }
}

extension SocialGraphItem {
    init(rawValue: SocialGraphItemResponse, baseURL: URL) {
        self.init(
            id: .init(rawValue.uuid),
            user: SocialUser(rawValue: rawValue.user, baseURL: baseURL)
        )
    }
}

extension SocialUser {
    init(rawValue: SocialUserResponse, baseURL: URL) {
        self.init(
            id: .init(rawValue.uuid),
            username: rawValue.username,
            avatar: .init(rawValue: rawValue.avatar?.image, baseURL: baseURL)
        )
    }
}

extension Offer {
    init?(rawValue: OfferResponse, baseURL: URL) {
        let location: Location?
        if let rawLocation = rawValue.location {
            location = .init(rawValue: rawLocation)
        } else {
            location = nil
        }
        let address = CNMutablePostalAddress()
        if let street = rawValue.address?.street {
            if let houseNumber = rawValue.address?.housenumber {
                address.street = [street, houseNumber].joined(separator: " ")
            } else {
                address.street = street
            }
        }
        if let city = rawValue.address?.city {
            address.city = city
        }
        if let zip = rawValue.address?.zip {
            address.postalCode = zip
        }
        let region: Region?
        if let rawRegion = rawValue.region {
            region = .init(rawValue: rawRegion)
        } else {
            region = nil
        }
        self.init(
            id: .init(rawValue.uuid),
            title: rawValue.title,
            summary: rawValue.summary,
            description: rawValue.description,
            image: .init(rawValue: rawValue.image, baseURL: baseURL),
            date: rawValue.validFrom,
            region: region,
            location: location,
            address: address,
            discount: rawValue.discount,
            type: StoreType(rawValue: rawValue.storeType),
            voucherRedemption: VoucherRedemptionState(
                rawValue: rawValue.voucherRedeem,
                genericVoucher: rawValue.genericVoucher
            ),
            websiteUrl: rawValue.websiteUrl
        )
    }
}

extension Offer.StoreType {
    init(rawValue: OfferResponse.StoreType) {
        switch rawValue {
        case .shop:
            self = .shop
        case .online:
            self = .online
        }
    }
}

extension Offer.VoucherRedemptionState {
    init(rawValue: VoucherRedemptionResponse, genericVoucher: String?) {
        if let genericVoucher {
            self = .generic(code: genericVoucher)
            return
        }
        if rawValue.vouchersExhausted {
            self = .exhausted
        } else if rawValue.redeemAvailable {
            self = .pending
        } else if let code = rawValue.redeemedCode {
            self = .redeemed(code: code, nextRedemptionDate: rawValue.redeemAvailableDate)
        } else {
            fatalError()
        }
    }
}

extension Survey {
    init?(rawValue: SurveyResponse) {
        if rawValue.finished, let evaluationURL = rawValue.evaluationUrl {
            self = .init(
                id: .init(rawValue.uuid),
                title: rawValue.title,
                description: rawValue.description,
                state: .evaluation(evaluationURL)
            )
        } else if !rawValue.finished, let participationURL = rawValue.surveyUrl {
            self = .init(
                id: .init(rawValue.uuid),
                title: rawValue.title,
                description: rawValue.description,
                state: .participation(participationURL)
            )
        } else {
            return nil
        }
    }
}
