//
//  Created by Kumpels and Friends on 16.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import SelectAvatarFeature
import XCTest

@MainActor
final class SelectAvatarFeatureTests: XCTestCase {
    func testFlow() async {
        let originalAvatar = IdentifiedImage.fake()
        let avatars = [IdentifiedImage.fake(), .fake()]
        //        let editUser = ActorIsolated<EditUser?>(nil)

        let store = TestStore(
            initialState: SelectAvatar.State(selectedAvatar: originalAvatar),
            reducer: SelectAvatar()
        ) {
            $0.avatarClient.loadAvatars = { avatars }
            //            $0.userClient.updateUser = {
            //                await editUser.setValue($0)
            //                return user
            //            }
        }
        await store.send(.task)

        await store.receive(.taskResult(.success(avatars))) {
            $0.avatars = .init(uniqueElements: avatars)
        }

        await store.send(.selectAvatar(avatars[0])) {
            $0.selectedAvatar = avatars[0]
        }

        //        await store.send(.saveButtonTapped) {
        //            $0.status = .saving
        //        }
        //
        //        let expectedEditUser = EditUser(
        //        )
        //
        //        await editUser.withValue { XCTAssertNoDifference(expectedEditUser, $0) }
        //
        //        await store.receive(.saveResult(.success(user)))
    }
}
