//
//  Created by Kumpels and Friends on 18.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SelectRegionFeature
import XCTest

@MainActor
final class SelectRegionFeatureTests: XCTestCase {
    func testFeature() async throws {
        let store = TestStore(initialState: .init(), reducer: SelectRegion())
        store.dependencies.regionsClient.regions = { _ in [.leipzig, .pirna, .dresden] }

        await store.send(.task) {
            $0.isLoading = true
        }

        await store.receive(.regionsResult(.success([Region.leipzig, .pirna, .dresden]))) {
            $0.isLoading = false
            $0.regions = [.leipzig, .pirna, .dresden]
        }

        await store.send(.binding(.set(\.$selectedRegion, .leipzig))) {
            $0.selectedRegion = .leipzig
        }
    }
}
