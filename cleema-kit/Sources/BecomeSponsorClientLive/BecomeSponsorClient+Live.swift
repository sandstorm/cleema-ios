//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import APIClient
import BecomeSponsorClient
import Foundation

public extension BecomeSponsorClient {
    static func live(from apiClient: APIClient) -> Self {
        .init(
            addMembership: { selectedPackageID, sponsorData in
                try await apiClient.addSponsorMembership(packageID: selectedPackageID, sponsorData: sponsorData)
            }
        )
    }
}
