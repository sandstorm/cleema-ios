import XCTest
import GoalFeature

final class MeasurementGoalFeatureTests: XCTestCase {
    func testFeature() {
        let store = TestStore(initialState: .init(progress: .init()), reducer: measurementGoalReducer, environment: ())

        store.send(.progress(.incrTapped)) {
            $0.progress.count = 2
            $0.progress.isDecrementButtonEnabled = true
        }

        store.send(.unitChanged(UnitLength.kilometers)) {
            $0.dimension = UnitLength.kilometers
        }
    }
}
