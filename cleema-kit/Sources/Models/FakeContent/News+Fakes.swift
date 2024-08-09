//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Fakes
import Foundation
import Tagged

public extension News {
    static func fake(
        id: ID = .init(rawValue: .init()),
        title: String = .word(),
        description: String = .sentence() + "\n\n" + .sentence(),
        teaser: String = .sentence(),
        date: Date = .now,
        publishedDate: Date = .now,
        tags: Set<Tag> = .init((1 ... 10).map { _ in .fake() }),
        imageID: UInt = 1,
        type: News.NewsType = .allCases.randomElement()!,
        isFaved: Bool = Bool.random()
    ) -> Self {
        .init(
            id: id,
            title: title,
            description: description,
            teaser: teaser,
            date: date,
            publishedDate: publishedDate,
            tags: tags,
            image: .init(
                url: .lorem(keyword: "Dresden", lock: imageID),
                width: CGSize.loremSize.width,
                height: CGSize.loremSize.height,
                scale: CGFloat.loremScale
            ),
            type: type,
            isFaved: isFaved
        )
    }
}

extension URL {
    static func lorem(keyword: String, lock: UInt, width: UInt? = nil) -> Self {
        let width = width ?? UInt(CGSize.loremSize.width)
        return URL(
            string: "https://loremflickr.com/\(width)/460/\(keyword)?lock=\(lock + 456_871)"
        )!
    }
}

#if canImport(UIKit)
import UIKit
extension CGSize {
    static var loremSize: CGSize {
        UIScreen.main.nativeBounds.size
    }
}

extension CGFloat {
    static var loremScale: CGFloat {
        UIScreen.main.scale
    }
}
#else
extension CGSize {
    static var loremSize: CGSize {
        .init(width: 800, height: 400)
    }
}

extension CGFloat {
    static var loremScale: CGFloat {
        3
    }
}
#endif
