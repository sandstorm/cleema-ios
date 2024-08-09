//
//  Created by Kumpels and Friends on 05.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
@testable import ProfileEditFeature
import SelectAvatarFeature
import XCTest

@MainActor
final class ProfileEditFeatureTests: XCTestCase {
    func testRemoteUserEditing() async {
        let userID = UUID()
        let avatarID = UUID()
        let date = Date.now
        let editUser = ActorIsolated<EditUser?>(nil)
        let user = User(
            id: .init(userID),
            name: "Bernd",
            region: .leipzig,
            joinDate: date,
            kind: .remote(password: "1234567890", email: "bernd@test.de"),
            acceptsSurveys: false,
            referralCode: "00000000-0000-0000-0000",
            avatar: .fake(id: .init(avatarID))
        )

        let savedUser = User(
            id: .init(userID),
            name: "Hans",
            region: .pirna,
            joinDate: date,
            kind: .remote(password: "1234567", email: "hans@bernd.de"),
            acceptsSurveys: true,
            referralCode: "00000000-0000-0000-0000"
        )

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit()) {
            $0.emailValidator = .live
            $0.userClient.updateUser = {
                await editUser.setValue($0)
                return savedUser
            }
        }

        XCTAssertEqual(.leipzig, store.state.selectRegionState.selectedRegion)
        XCTAssertTrue(store.state.editedUser.password.isEmpty)
        XCTAssertTrue(store.state.editedUser.passwordConfirmation.isEmpty)

        await store.send(.binding(.set(\.$editedUser.name, "Hans"))) {
            $0.editedUser.name = "Hans"
        }

        await store.send(.binding(.set(\.$editedUser.email, "hans@bernd.de"))) {
            $0.editedUser.email = "hans@bernd.de"
        }

        await store.send(.selectRegion(.binding(.set(\.$selectedRegion, .pirna)))) {
            $0.selectRegionState.selectedRegion = .pirna
            $0.editedUser.region = .pirna
        }

        await store.send(.binding(.set(\.$editedUser.acceptsSurveys, true))) {
            $0.editedUser.acceptsSurveys = true
        }

        await store.send(.binding(.set(\.$editedUser.password, "12345678901"))) {
            $0.editedUser.password = "12345678901"
        }

        XCTAssertTrue(store.state.editedUser.showsPasswordConfirmationField)

        await store.send(.saveButtonTapped) {
            $0.status = .editing([.notMatching, .oldPasswordNotMatching])
        }

        await store.send(.binding(.set(\.$editedUser.passwordConfirmation, "12345678901"))) {
            $0.editedUser.passwordConfirmation = "12345678901"
        }

        await store.send(.saveButtonTapped) {
            $0.status = .editing([.oldPasswordNotMatching])
        }

        await store.send(.binding(.set(\.$editedUser.oldPassword, "1234567890"))) {
            $0.editedUser.oldPassword = "1234567890"
        }

        await store.send(.saveButtonTapped) {
            $0.status = .saving
        }

        let expectedEditUser = EditUser(
            username: "Hans",
            password: "12345678901",
            email: "hans@bernd.de",
            acceptsSurveys: true,
            region: .pirna
        )

        await editUser.withValue { XCTAssertNoDifference(expectedEditUser, $0) }

        await store.receive(.saveResult(.success(savedUser)))
    }

    func testRemoteUserSavingWithUnchangedValues() async {
        let user = User(
            id: .init(.init()),
            name: "Hans",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "1234567", email: "hans@bernd.de"),
            acceptsSurveys: true,
            referralCode: "00000000-0000-0000-0000",
            avatar: .fake()
        )

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit())

        await store.send(.saveButtonTapped)

        await store.receive(.saveResult(.success(user)))
    }

    func testRemoteUserChangingOnlyAcceptSurveys() async {
        let user = User(
            id: .init(.init()),
            name: "Hans",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "1234567", email: "hans@bernd.de"),
            acceptsSurveys: true,
            referralCode: "00000000-0000-0000-0000",
            avatar: .fake()
        )
        let editUser = ActorIsolated<EditUser?>(nil)

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit()) {
            $0.userClient.updateUser = {
                await editUser.setValue($0)
                return user
            }
        }

        await store.send(.binding(.set(\.$editedUser.acceptsSurveys, false))) {
            $0.editedUser.acceptsSurveys = false
        }

        await store.send(.saveButtonTapped) {
            $0.status = .saving
        }

        let expectedEditUser = EditUser(
            acceptsSurveys: false
        )

        await editUser.withValue { XCTAssertNoDifference(expectedEditUser, $0) }

        await store.receive(.saveResult(.success(user)))
    }

    func testRemoteUserChangingNameAndPassword() async {
        let user = User(
            id: .init(.init()),
            name: "Hans",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "1234567890", email: "hans@bernd.de"),
            acceptsSurveys: true,
            referralCode: "00000000-0000-0000-0000",
            avatar: .fake()
        )
        let editUser = ActorIsolated<EditUser?>(nil)

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit()) {
            $0.userClient.updateUser = {
                await editUser.setValue($0)
                return user
            }
        }

        await store.send(.binding(.set(\.$editedUser.name, "Clara"))) {
            $0.editedUser.name = "Clara"
        }

        await store.send(.binding(.set(\.$editedUser.password, "0987654321"))) {
            $0.editedUser.password = "0987654321"
        }

        await store.send(.binding(.set(\.$editedUser.passwordConfirmation, "0987654321"))) {
            $0.editedUser.passwordConfirmation = "0987654321"
        }

        await store.send(.binding(.set(\.$editedUser.oldPassword, "1234567890"))) {
            $0.editedUser.oldPassword = "1234567890"
        }

        await store.send(.saveButtonTapped) {
            $0.status = .saving
        }

        let expectedEditUser = EditUser(
            username: "Clara",
            password: "0987654321"
        )

        await editUser.withValue { XCTAssertNoDifference(expectedEditUser, $0) }

        await store.receive(.saveResult(.success(user)))
    }

    func testRemoteUserChangingAvatar() async {
        let originalAvatar = IdentifiedImage.fake()
        let user = User(
            id: .init(.init()),
            name: "Hans",
            region: .pirna,
            joinDate: .now,
            kind: .remote(password: "1234567", email: "hans@bernd.de"),
            acceptsSurveys: true,
            referralCode: "00000000-0000-0000-0000",
            avatar: originalAvatar
        )

        let editUser = ActorIsolated<EditUser?>(nil)

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit()) {
            $0.userClient.updateUser = {
                await editUser.setValue($0)
                return user
            }
        }
        store.exhaustivity = .off

        await store.send(.selectAvatarTapped) {
            $0.selectAvatarState = .init(selectedAvatar: originalAvatar)
        }

        let expectedAvatar = IdentifiedImage.fake()
        await store.send(.selectAvatar(.selectAvatar(expectedAvatar)))

        await store.send(.selectAvatar(.saveButtonTapped)) {
            $0.editedUser.avatar = expectedAvatar
            $0.selectAvatarState = nil
        }

        await store.send(.saveButtonTapped) {
            $0.status = .saving
        }

        let expectedEditUser = EditUser(
            avatar: expectedAvatar
        )

        await editUser.withValue { XCTAssertNoDifference(expectedEditUser, $0) }

        await store.receive(.saveResult(.success(user)))
    }

    func testRemoteUserDismissChangingAvatar() async {
        let avatar = IdentifiedImage.fake()
        var user = User.emptyRemote
        user.avatar = avatar

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit())

        await store.send(.selectAvatarTapped) {
            $0.selectAvatarState = SelectAvatar.State(selectedAvatar: avatar)
        }

        await store.send(.dismissSelectAvatarSheet) {
            $0.selectAvatarState = nil
        }

        await store.send(.selectAvatarTapped) {
            $0.selectAvatarState = SelectAvatar.State(selectedAvatar: avatar)
        }

        await store.send(.selectAvatar(.cancelButtonTapped)) {
            $0.selectAvatarState = nil
        }
    }

    func testLocalUserEditing() async {
        let userID = UUID()
        let date = Date.now
        let user = User(
            id: .init(userID),
            name: "Hans",
            region: .leipzig,
            joinDate: date,
            acceptsSurveys: false,
            referralCode: ""
        )

        let savedUser = User(
            id: .init(userID),
            name: "Bernd",
            region: .pirna,
            joinDate: date,
            acceptsSurveys: true,
            referralCode: ""
        )

        let editUser = ActorIsolated<EditUser?>(nil)

        let store = TestStore(initialState: .init(user: user), reducer: ProfileEdit()) {
            $0.userClient.updateUser = {
                await editUser.setValue($0)
                return savedUser
            }
        }

        await store.send(.binding(.set(\.$editedUser.name, ""))) {
            $0.editedUser.name = ""
        }

        await store.send(.saveButtonTapped) {
            $0.status = .editing(.name)
        }

        await store.send(.binding(.set(\.$editedUser.name, "Bernd"))) {
            $0.editedUser.name = "Bernd"
        }

        await store.send(.selectRegion(.binding(.set(\.$selectedRegion, .pirna)))) {
            $0.selectRegionState.selectedRegion = .pirna
            $0.editedUser.region = .pirna
        }

        await store.send(.binding(.set(\.$editedUser.acceptsSurveys, true))) {
            $0.editedUser.acceptsSurveys = true
        }

        let expectedEditUser = EditUser(
            username: "Bernd",
            acceptsSurveys: true,
            region: .pirna
        )

        await store.send(.saveButtonTapped) {
            $0.status = .saving
        }

        await editUser.withValue { XCTAssertNoDifference(expectedEditUser, $0) }

        await store.receive(.saveResult(.success(savedUser)))
    }
}
