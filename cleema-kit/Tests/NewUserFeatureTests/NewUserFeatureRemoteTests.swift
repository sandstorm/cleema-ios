//
//  Created by Kumpels and Friends on 02.03.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Models
import NewUserFeature
import XCTest

@MainActor
final class NewUserFeatureRemoteTests: XCTestCase {
    struct RegistrationValue: Equatable {
        var name: String, password: String, email: String, acceptsSurveys: Bool, regionID: Region.ID,
            referralCode: String? = nil
    }

    func testInputValidation() async throws {
        let store = TestStore(initialState: .init(selection: .server), reducer: NewUser()) {
            $0.emailValidator = .alwaysValid
        }

        await store.send(.registerUser(.binding(.set(\.$name, "name")))) {
            $0.registerUserState.name = "name"
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.passwordLength, .region])
        }

        await store.send(.registerUser(.binding(.set(\.$email, "mail")))) {
            $0.registerUserState.email = "mail"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.passwordLength, .region])
        }

        await store.send(.registerUser(.binding(.set(\.$password, "1234567890")))) {
            $0.registerUserState.password = "1234567890"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.notMatching, .region])
        }

        await store.send(.registerUser(.binding(.set(\.$password, "12345")))) {
            $0.registerUserState.password = "12345"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.passwordLength, .notMatching, .region])
        }

        await store.send(.registerUser(.binding(.set(\.$confirmation, "12345")))) {
            $0.registerUserState.confirmation = "12345"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.passwordLength, .region])
        }

        await store.send(.registerUser(.binding(.set(\.$confirmation, "1234567890")))) {
            $0.registerUserState.confirmation = "1234567890"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.passwordLength, .notMatching, .region])
        }

        await store.send(.registerUser(.binding(.set(\.$password, "1234567890")))) {
            $0.registerUserState.password = "1234567890"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing(.region)
        }

        await store.send(.registerUser(.selectRegion(.binding(.set(\.$selectedRegion, .leipzig))))) {
            $0.registerUserState.selectRegionState.selectedRegion = .leipzig
            $0.status = .editing()
        }

        store.dependencies.emailValidator = .failing

        await store.send(.registerUser(.binding(.set(\.$email, "mail@host.com")))) {
            $0.registerUserState.email = "mail@host.com"
            $0.status = .editing()
        }

        await store.send(.saveTapped) {
            $0.status = .editing(.email)
        }

        store.dependencies.emailValidator = .alwaysValid

        await store.send(.registerUser(.binding(.set(\.$email, "mail@host.com")))) {
            $0.registerUserState.email = "mail@host.com"
            $0.status = .editing()
        }

        await store.send(.registerUser(.binding(.set(\.$name, "")))) {
            $0.registerUserState.name = ""
        }

        await store.send(.saveTapped) {
            $0.status = .editing(.name)
        }
    }

    func testInvalidContentWillNotPassedOnToTheClient() async throws {
        let registration = ActorIsolated<RegistrationValue?>(nil)

        let store = TestStore(
            initialState: .init(
                registerUserState: .init(),
                selection: .server
            ),
            reducer: NewUser()
        ) {
            $0.emailValidator = .failing
            $0.userClient.register = { registerUser in
                await registration
                    .setValue(
                        RegistrationValue(
                            name: registerUser.username,
                            password: registerUser.password,
                            email: registerUser.email,
                            acceptsSurveys: registerUser.acceptsSurveys,
                            regionID: registerUser.region.id
                        )
                    )
            }
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.name, .passwordLength, .email, .name, .region])
        }

        await registration.withValue { XCTAssertNil($0) }
    }

    func testSuccessfulRegistrationInClient() async throws {
        let fixedID = UUID()
        let fixedDate = Date.now
        let registration = LockIsolated<RegistrationValue?>(nil)
        _ = User(
            id: .init(rawValue: fixedID),
            name: "registered name",
            region: .leipzig,
            joinDate: Date(),
            kind: .remote(password: "registered-1233456", email: "hi@there.com"),
            acceptsSurveys: true,
            referralCode: "1233456"
        )
        let savedUser = LockIsolated<UserValue?>(nil)

        let store = TestStore(
            initialState: .init(
                registerUserState: .init(
                    name: "name",
                    password: "1234567890",
                    confirmation: "1234567890",
                    email: "hi@there.com",
                    acceptsSurveys: true,
                    selectRegionState: .init(regions: [.leipzig, .dresden], selectedRegion: .leipzig)
                ),
                selection: .server
            ),
            reducer: NewUser()
        ) {
            $0.emailValidator = .alwaysValid
            $0.uuid = .constant(fixedID)
            $0.date = .constant(fixedDate)
            $0.userClient.register = { registerUser in
                registration
                    .setValue(RegistrationValue(
                        name: registerUser.username,
                        password: registerUser.password,
                        email: registerUser.email,
                        acceptsSurveys: registerUser.acceptsSurveys,
                        regionID: registerUser.region.id
                    ))
            }
            $0.userClient.saveUser = { savedUser.setValue($0) }
        }

        await store.send(.saveTapped) {
            $0.status = .saving
        }

        XCTAssertNoDifference(
            RegistrationValue(
                name: "name",
                password: "1234567890",
                email: "hi@there.com",
                acceptsSurveys: true,
                regionID: Region.leipzig.id
            ),
            registration.value
        )
        let expectedCredentials = Credentials(username: "name", password: "1234567890", email: "hi@there.com")
        XCTAssertNoDifference(.pending(expectedCredentials), savedUser.value)
        await store.receive(.registerResult(.success(expectedCredentials))) {
            $0.status = .pendingConfirmation(expectedCredentials)
        }
    }

    func testFailingRegistrationInClient() async throws {
        final class TestError: NSError {
            override var localizedDescription: String { "Test error message" }
            init() {
                super.init(domain: "Test domain", code: 42)
            }

            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError()
            }
        }

        let fixedID = UUID()
        let fixedDate = Date.now
        let error = TestError()

        let store = TestStore(
            initialState: .init(
                registerUserState: .init(
                    name: "name",
                    password: "1234567890",
                    confirmation: "1234567890",
                    email: "hi@there.com",
                    selectRegionState: .init(regions: [.leipzig, .dresden], selectedRegion: .dresden)
                ),
                selection: .server
            ),
            reducer: NewUser()
        ) {
            $0.emailValidator = .alwaysValid
            $0.uuid = .constant(fixedID)
            $0.date = .constant(fixedDate)

            $0.userClient.register = { _ in
                throw error
            }
        }

        await store.send(.saveTapped) {
            $0.status = .saving
        }

        await store.receive(.registerResult(.failure(error))) {
            $0.status = .error(error.localizedDescription)
        }
    }

    func testResetWhenInPendingConfirmationDeletesUserInTheClient() async throws {
        let deleteInvoked = LockIsolated(false)
        let store = TestStore(
            initialState: .init(
                createUserState: .init(name: "gunk"),
                registerUserState: .init(
                    name: "name",
                    password: "1234567890",
                    confirmation: "1234567890",
                    email: "hi@there.com",
                    selectRegionState: .init(regions: [.leipzig, .dresden], selectedRegion: .dresden)
                ),
                status: .pendingConfirmation(.init(username: "", password: "", email: "")),
                selection: .server
            ),
            reducer: NewUser()
        ) {
            $0.userClient.delete = {
                deleteInvoked.setValue(true)
                return true
            }
        }

        await store.send(.resetTapped) {
            $0.status = .editing([])
            $0.registerUserState = .init()
            $0.createUserState = .init()
            $0.selection = .local
        }

        XCTAssertTrue(deleteInvoked.value)
    }

    func testReferralCodeIsSentToTheAPIClient() async throws {
        let fixedID = UUID()
        let fixedDate = Date.now
        let registration = LockIsolated<RegistrationValue?>(nil)

        let expected = RegistrationValue(
            name: "name",
            password: "1234567890",
            email: "hi@there.com",
            acceptsSurveys: true,
            regionID: Region.leipzig.id,
            referralCode: "abcd"
        )

        let store = TestStore(
            initialState: .init(
                registerUserState: .init(
                    name: "name",
                    password: "1234567890",
                    confirmation: "1234567890",
                    email: "hi@there.com",
                    acceptsSurveys: true,
                    selectRegionState: .init(regions: [.leipzig, .dresden], selectedRegion: .leipzig),
                    referralCode: "abcd"
                ),
                selection: .server
            ),
            reducer: NewUser()
        ) {
            $0.emailValidator = .alwaysValid
            $0.uuid = .constant(fixedID)
            $0.date = .constant(fixedDate)
            $0.userClient.register = { registerUser in
                registration
                    .setValue(
                        RegistrationValue(
                            name: registerUser.username,
                            password: registerUser.password,
                            email: registerUser.email,
                            acceptsSurveys: registerUser.acceptsSurveys,
                            regionID: registerUser.region.id,
                            referralCode: registerUser.referralCode
                        )
                    )
            }
            $0.userClient.saveUser = { _ in }
        }

        store.exhaustivity = .off

        await store.send(.saveTapped) {
            $0.status = .saving
        }

        XCTAssertNoDifference(expected, registration.value)
    }
}
