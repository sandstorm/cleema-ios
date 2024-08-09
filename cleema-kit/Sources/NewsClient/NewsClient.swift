//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

public struct NewsClient {
    public var news: @Sendable (String, Region.ID?) async throws -> [News]
    public var tags: @Sendable () async throws -> [Tag]
    public var fav: @Sendable (News.ID, Bool) async throws -> News
    public var favedNewsStream: @Sendable () -> AsyncThrowingStream<[News], Error>
    public var markAsRead: @Sendable (News.ID) async throws -> Void

    public init(
        news: @escaping @Sendable (String, Region.ID?) async throws -> [News],
        tags: @escaping @Sendable () async throws -> [Tag],
        fav: @escaping @Sendable (News.ID, Bool) async throws -> News,
        favedNewsStream: @escaping @Sendable () -> AsyncThrowingStream<[News], Error>,
        markAsRead: @escaping @Sendable (News.ID) async throws -> Void
    ) {
        self.news = news
        self.tags = tags
        self.fav = fav
        self.favedNewsStream = favedNewsStream
        self.markAsRead = markAsRead
    }
}

public extension NewsClient {
    private static let fakeNews: [News] = [
        .fake(imageID: 1, isFaved: true),
        .fake(imageID: 2, isFaved: false),
        .fake(imageID: 3, isFaved: true),
        .fake(imageID: 4, isFaved: false),
        .fake(imageID: 5, isFaved: true),
        .fake(imageID: 6, isFaved: false)
    ]

    static let preview: Self = .init(
        news: { _, _ in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 5)
            return fakeNews
        },
        tags: {
            [.fake(value: "Leipzig"), .fake(value: "Dresden")]
        },
        fav: { _, _ in
            fakeNews[0]
        },
        favedNewsStream: {
            AsyncThrowingStream(unfolding: {
                fakeNews.filter { $0.isFaved }
            })
        },
        markAsRead: { _ in
        }
    )

    static let unimplemented: NewsClient = .init(
        news: XCTestDynamicOverlay.unimplemented("\(Self.self).news"),
        tags: XCTestDynamicOverlay.unimplemented("\(Self.self).tags"),
        fav: XCTestDynamicOverlay.unimplemented("\(Self.self).fav"),
        favedNewsStream: XCTestDynamicOverlay.unimplemented("\(Self.self).favedNewsStream"),
        markAsRead: XCTestDynamicOverlay.unimplemented("\(Self.self).markAsRead")
    )
}

public enum NewsClientKey: TestDependencyKey {
    public static let testValue = NewsClient.unimplemented
    public static let previewValue = NewsClient.preview
}

public extension DependencyValues {
    var newsClient: NewsClient {
        get { self[NewsClientKey.self] }
        set { self[NewsClientKey.self] = newValue }
    }
}
