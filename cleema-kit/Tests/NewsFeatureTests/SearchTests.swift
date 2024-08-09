//
//  Created by Kumpels and Friends on 17.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import NewsFeature
import XCTest

@MainActor
final class SearchTests: XCTestCase {
    func testSelectingATag() async throws {
        let tags: [Tag] = [.fake(), .fake(), .fake(), .fake()]
        let store = TestStore(
            initialState: .init(
                region: Region.leipzig.id,
                suggestionState: .init(suggestions: [.tag(tags.randomElement()!)], tags: tags)
            ),
            reducer: Search()
        )

        let tag = tags.randomElement()!
        await store.send(.tappedTag(tag)) {
            $0.term = tag.value
            $0.suggestionState.suggestions = []
        }

        await store.receive(.submit)
    }
}
