//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Overture
import TrophiesFeature
import XCTest

@MainActor
final class TrophiesFeatureTests: XCTestCase {
    func testFeature() async {
        let date = Date()

        let store = TestStore(
            initialState: .init(),
            reducer: Trophies()
        ) {
            $0.date = .constant(date)
            $0.uuid = .incrementing
            $0.trophyClient.loadTrophies = { [] }
        }

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success([]))) {
            $0.isLoading = false
        }

        let trophyFive = Trophy(
            id: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!),
            date: store.dependencies.date(),
            title: "5 Quizfragen beantwortet",
            image: .fake()
        )

        store.dependencies.trophyClient.loadTrophies = { [trophyFive] in [trophyFive] }

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadResponse(.success([trophyFive]))) {
            $0.isLoading = false
            $0.trophies = [trophyFive]
        }

        let trophyFifty = Trophy(
            id: .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!),
            date: store.dependencies.date(),
            title: "50 Quizfragen beantwortet",
            image: .fake()
        )

        store.dependencies.trophyClient.loadTrophies = { [trophyFive, trophyFifty] in [trophyFive, trophyFifty] }

        await store.send(.load) {
            $0.isLoading = true
        }

        await store
            .receive(.loadResponse(.success([trophyFive, trophyFifty]))) {
                $0.isLoading = false
                $0.trophies = [trophyFive, trophyFifty]
            }

        await store.send(.setNavigation(selection: trophyFifty.id)) {
            $0.selection = .init(trophyFifty, id: trophyFifty.id)
        }

        await store.send(.setNavigation(selection: nil)) {
            $0.selection = nil
        }
    }
}
