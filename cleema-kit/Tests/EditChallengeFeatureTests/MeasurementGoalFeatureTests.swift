//
//  Created by Kumpels and Friends on 16.07.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import EditChallengeFeature
import XCTest

final class MeasurementGoalFeatureTests: XCTestCase {
    func testFeature() {
        let store = TestStore(
            initialState: .init(count: 42, availableUnits: [.kilometers, .kilograms]),
            reducer: MeasurementGoal()
        )

        store.send(.binding(.set(\.$count, 10))) {
            $0.count = 10
        }

        store.send(.unitChanged(.kilograms)) {
            $0.unit = .kilograms
        }

        store.send(.unitChanged(.kilometers)) {
            $0.unit = .kilometers
        }
    }
}
