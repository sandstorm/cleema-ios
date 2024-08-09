//
//  Created by Kumpels and Friends on 18.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

@testable import APIClient
import Foundation
import PlaygroundSupport
import URLRouting

PlaygroundPage.current.needsIndefiniteExecution = true

var client = APIClient(
    baseURI: "https://api.cleema.app",
    token: "<#Insert token#>"
)

Task {
    do {
        try await client.login(user: "tmkfi", password: "<#pw#>")
        // try await client.leave(challengeWithID: .init(rawValue: UUID(uuidString: "a31cb9d0-6cca-4654-905b-b5b6bb8f44b6")!))
        // try await client.join(challengeWithID: .init(rawValue: UUID(uuidString: "a31cb9d0-6cca-4654-905b-b5b6bb8f44b6")!))
        try await client.joinedChallenges()
        try await client.challenges()
    } catch {
        print(error)
    }
}
