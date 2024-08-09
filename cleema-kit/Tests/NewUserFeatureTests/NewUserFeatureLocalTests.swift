//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import NewUserFeature
import XCTest

@MainActor
final class NewUserFeatureLocalTests: XCTestCase {
    func testFlow() async {
        let id = UUID()
        let date = Date()
        let savedUser = ActorIsolated<User?>(nil)
        let expectedRegions = [Region.leipzig, .dresden, .pirna]

        let store = TestStore(
            initialState: .init(),
            reducer: NewUser()
        ) {
            $0.uuid = .constant(id)
            $0.date = .constant(date)
            $0.userClient.saveUser = { await savedUser.setValue($0.user) }
            $0.regionsClient.regions = { _ in expectedRegions }
        }

        await store.send(.createUser(.selectRegion(.task))) {
            $0.createUserState.selectRegionState.isLoading = true
        }

        await store.receive(.createUser(.selectRegion(.regionsResult(.success(expectedRegions))))) {
            $0.createUserState.selectRegionState.isLoading = false
            $0.createUserState.selectRegionState.regions = [.leipzig, .dresden, .pirna]
        }

        await store.send(.saveTapped) {
            $0.status = .editing([.name, .region])
        }

        await savedUser.withValue { XCTAssertNil($0) }

        await store.send(.createUser(.selectRegion(.binding(.set(\.$selectedRegion, nil))))) {
            $0.status = .editing()
        }

        for region in expectedRegions {
            await store.send(.createUser(.selectRegion(.binding(.set(\.$selectedRegion, region))))) {
                $0.createUserState.selectRegionState.selectedRegion = region
            }
        }

        await store.send(.createUser(.binding(.set(\.$name, "Boris Becker")))) {
            $0.createUserState.name = "Boris Becker"
            $0.status = .editing()
        }

        await store.send(.createUser(.binding(.set(\.$name, "")))) {
            $0.createUserState.name = ""
            $0.status = .editing()
        }

        await store.send(.createUser(.binding(.set(\.$name, "    ")))) {
            $0.createUserState.name = "    "
        }

        await store.send(.saveTapped) {
            $0.status = .editing(.name)
        }

        await savedUser.withValue { XCTAssertNil($0) }

        await store.send(.createUser(.binding(.set(\.$name, "   Jan Ullrich    ")))) {
            $0.createUserState.name = "   Jan Ullrich    "
            $0.status = .editing()
        }

        await store.send(.createUser(.selectRegion(.binding(.set(\.$selectedRegion, nil))))) {
            $0.createUserState.selectRegionState.selectedRegion = nil
        }

        let randomRegion = expectedRegions.randomElement()!
        await store.send(.createUser(.selectRegion(.binding(.set(\.$selectedRegion, randomRegion))))) {
            $0.createUserState.selectRegionState.selectedRegion = randomRegion
        }

        await store.send(.createUser(.binding(.set(\.$acceptsSurveys, true)))) {
            $0.createUserState.acceptsSurveys = true
        }

        await store.send(.saveTapped) {
            $0.status = .saving
        }

        let expectedUser = User(
            id: .init(rawValue: id),
            name: "Jan Ullrich",
            region: randomRegion,
            joinDate: date,
            kind: .local,
            acceptsSurveys: true,
            referralCode: ""
        )
        await store.receive(.saveResult(.success(expectedUser))) {
            $0.status = .done(expectedUser)
        }

        await savedUser.withValue { XCTAssertNoDifference(expectedUser, $0) }

        await store.finish()
    }

    func testFailingSaveInUserClient() async throws {
        final class TestError: NSError {
            override var localizedDescription: String { "Error message" }
        }

        let error = TestError(domain: "Error message", code: 42)

        let store = TestStore(
            initialState: .init(createUserState: .init(
                name: "User",
                selectRegionState: .init(regions: [.leipzig], selectedRegion: .leipzig, isLoading: false)
            )),
            reducer: NewUser()
        ) {
            $0.userClient.saveUser = { _ in throw error }
            $0.uuid = .constant(.init())
            $0.date = .constant(.init())
            $0.log = .noop
        }

        await store.send(.saveTapped) {
            $0.status = .saving
        }

        await store.receive(.saveResult(.failure(error))) {
            $0.status = .error("Error message")
        }

        await store.finish()
    }
}
