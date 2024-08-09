//
//  Created by Kumpels and Friends on 22.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    func loadAbout() async throws -> InfoContent {
        let result: InfoContentResponse = try await decoded(for: .info(.about), with: token)
        return InfoContent(text: result.content)
    }

    @Sendable
    func loadPrivacyPolicy() async throws -> InfoContent {
        let result: InfoContentResponse = try await decoded(for: .info(.privacyPolicy), with: token)
        return InfoContent(text: result.content)
    }

    @Sendable
    func loadImprint() async throws -> InfoContent {
        let result: InfoContentResponse = try await decoded(for: .info(.imprint), with: token)
        return InfoContent(text: result.content)
    }

    @Sendable
    func loadPartnership() async throws -> InfoContent {
        let result: InfoContentResponse = try await decoded(for: .info(.partnership), with: token)
        return InfoContent(text: result.content)
    }

    @Sendable
    func loadSponsorship() async throws -> InfoContent {
        let result: InfoContentResponse = try await decoded(for: .info(.sponsorship), with: token)
        return InfoContent(text: result.content)
    }
}
