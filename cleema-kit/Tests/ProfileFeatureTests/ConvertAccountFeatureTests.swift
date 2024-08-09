//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Models
import ProfileFeature
import UserClient
import XCTest

@MainActor
final class ConvertAccountFeatureTests: XCTestCase {
    struct RegistrationValue: Equatable {
        var name: String, password: String, email: String, acceptsSurveys: Bool, regionID: Region.ID
    }

    func testAccountConversion() async throws {
        let registration = LockIsolated<RegistrationValue?>(nil)
        let savedUserValue = LockIsolated<UserValue?>(nil)

        let expectedId: User.ID = .init()
        let store = TestStore(
            initialState: .init(
                registerUser: .init(
                    name: "name",
                    password: "1234567890",
                    confirmation: "1234567890",
                    email: "mail@domain.de",
                    acceptsSurveys: true,
                    selectRegionState: .init(selectedRegion: Region.leipzig)
                ),
                localUserId: expectedId
            ),
            reducer: ConvertAccount()
        ) {
            $0.emailValidator = .alwaysValid
            $0.userClient.register = { registerUser in
                registration.setValue(
                    RegistrationValue(
                        name: registerUser.username,
                        password: registerUser.password,
                        email: registerUser.email,
                        acceptsSurveys: registerUser.acceptsSurveys,
                        regionID: registerUser.region.id
                    )
                )
            }
            $0.userClient.saveUser = { savedUserValue.setValue($0) }
        }

        await store.send(.submitConvertAccountTapped)

        let expectedCredentials = Credentials(username: "name", password: "1234567890", email: "mail@domain.de")
        await store.receive(.convertAccountResult(.success(expectedCredentials)))
        XCTAssertNoDifference(
            RegistrationValue(
                name: "name",
                password: "1234567890",
                email: "mail@domain.de",
                acceptsSurveys: true,
                regionID: Region.leipzig.id
            ), registration.value
        )

        XCTAssertNoDifference(.pending(expectedCredentials), savedUserValue.value)
    }
}
