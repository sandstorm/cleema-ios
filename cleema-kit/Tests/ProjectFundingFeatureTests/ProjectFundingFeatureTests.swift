//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ProjectFundingFeature
import XCTest

@MainActor
final class ProjectFundingFeatureTests: XCTestCase {
    func testFeature() async throws {
        let id = Project.ID(rawValue: .init())
        let store = TestStore(
            initialState: .init(id: id, totalAmount: 1_000, currentAmount: 0, step: .amount(.five)),
            reducer: ProjectFunding()
        )
        let supportSpy: ActorIsolated<(Project.ID, Int)?> = .init(nil)
        store.dependencies.projectsClient.support = { id, amount in
            await supportSpy.setValue((id, amount))
        }

        await store.send(.steps(.amount(.binding(.set(\.$amount, 42))))) {
            $0.step = .amount(.custom(42))
        }

        await store.send(.steps(.amount(.supportTapped))) {
            $0.step = .pending
        }

        await supportSpy.withValue {
            XCTAssertEqual(id, $0?.0)
            XCTAssertEqual(42, $0?.1)
        }

        await store.receive(.supportResponse(.success(42))) {
            $0.step = .donation(amount: 42)
        }

        await store.send(.steps(.donation(.restartTapped))) {
            $0.step = .amount(.five)
        }
    }
}
