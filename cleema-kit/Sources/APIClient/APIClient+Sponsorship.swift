//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models

public extension APIClient {
    @Sendable
    func addSponsorMembership(packageID: SponsorPackage.ID, sponsorData: SponsorData) async throws {
        let request = APIRequest(data: AddSponsorMembershipRequest(packageID: packageID, sponsorData: sponsorData))

        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: token)
        let (_, response) = try await client.data(for: .sponsorship(.addMembership(request)))

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            return
        } else {
            throw InvalidResponse()
        }
    }
}
