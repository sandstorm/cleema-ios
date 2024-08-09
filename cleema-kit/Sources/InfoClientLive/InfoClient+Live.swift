//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import APIClient
import Foundation
import InfoClient

public extension InfoClient {
    static func live(from apiClient: APIClient) -> Self {
        .init(
            loadAbout: {
                try await apiClient.loadAbout()
            }, loadPrivacy: {
                try await apiClient.loadPrivacyPolicy()
            }, loadImprint: {
                try await apiClient.loadImprint()
            }, loadPartnership: {
                try await apiClient.loadPartnership()
            }, loadSponsorship: {
                try await apiClient.loadSponsorship()
            }
        )
    }
}
