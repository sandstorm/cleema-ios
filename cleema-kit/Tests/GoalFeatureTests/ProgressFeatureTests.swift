import Foundation
import GoalFeature
import XCTest

final class ProgressFeatureTests: XCTestCase {
    func testFeature() {
        let store = TestStore(initialState: .init(), reducer: progressReducer, environment: ())

        store.send(.incrTapped) {
            $0.count = 2
            $0.isDecrementButtonEnabled = true
        }

        store.send(.incrTapped) {
            $0.count = 3
        }

        store.send(.decrTapped) {
            $0.count = 2
        }

        store.send(.decrTapped) {
            $0.count = 1
            $0.isDecrementButtonEnabled = false
        }

        store.send(.decrTapped)
    }
}
