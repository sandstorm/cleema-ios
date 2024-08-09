//
//  Created by Kumpels and Friends on 24.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

public struct Region: Identifiable, Hashable, Codable {
    public typealias ID = Tagged<Region, UUID>

    public var id: ID = .init(rawValue: .init())
    public var name: String

    public init(id: Tagged<Region, UUID> = .init(rawValue: .init()), name: String) {
        self.id = id
        self.name = name
    }
}

public extension Region {
    static let dresden: Self = .init(
        id: .init(rawValue: .init(uuidString: "d711cb16-a6e1-41ae-9018-73260a8f0aed")!),
        name: "Dresden"
    )
    static let leipzig: Self = .init(
        id: .init(rawValue: .init(uuidString: "7ff5993e-b44f-4774-bc7a-e4c1e496187f")!),
        name: "Leipzig"
    )
    static let pirna: Self = .init(
        id: .init(rawValue: .init(uuidString: "CF14BA89-E90C-4916-8AC0-204E5E74DAE8")!),
        name: "Pirna"
    )
}
