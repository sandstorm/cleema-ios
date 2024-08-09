//
//  File.swift
//  
//
//  Created by Justin on 07.05.24.

import Foundation

struct JoinedChallengeResponse: Codable {
    var createdAt: Date
    var updatedAt: Date
    var answers: [Answer]?
    var collectiveProgress: CollectiveProgressResponse?
}


struct CollectiveProgressResponse: Codable {
    var totalAnswers: Int
    var succeededAnswers: Int
    var user: SocialUserResponse
}
