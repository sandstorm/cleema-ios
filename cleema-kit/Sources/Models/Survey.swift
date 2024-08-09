//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Tagged

public struct Survey: Equatable, Identifiable {
    public typealias ID = Tagged<Survey, UUID>

    public enum State: Equatable {
        case participation(URL)
        case evaluation(URL)
    }

    public var id: ID

    public var title: String
    public var description: String
    public var state: State

    public init(id: ID, title: String, description: String, state: State) {
        self.id = id
        self.title = title
        self.description = description
        self.state = state
    }
}
