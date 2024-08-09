//
//  Created by Kumpels and Friends on 17.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct News: Identifiable, Hashable {
    public typealias ID = Tagged<News, UUID>

    public enum NewsType: CaseIterable {
        case news
        case tip
    }

    public var id: ID
    public var title: String
    public var description: String
    public var teaser: String
    public var date: Date
    public var publishedDate: Date
    public var tags: [Tag]
    public var image: RemoteImage?
    public var type: NewsType
    public var isFaved: Bool

    public init(
        id: ID,
        title: String,
        description: String,
        teaser: String,
        date: Date,
        publishedDate: Date,
        tags: Set<Tag>,
        image: RemoteImage?,
        type: NewsType,
        isFaved: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.teaser = teaser
        self.date = date
        self.publishedDate = publishedDate
        self.tags = tags.sorted { $0.value.localizedCompare($1.value) == .orderedAscending }
        self.image = image
        self.type = type
        self.isFaved = isFaved
    }
}
