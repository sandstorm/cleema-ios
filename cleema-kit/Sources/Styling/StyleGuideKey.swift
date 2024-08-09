//
//  Created by Kumpels and Friends on 01.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

enum StyleGuideKey: EnvironmentKey {
    static var defaultValue: StyleGuide = .init()
}

public extension EnvironmentValues {
    var styleGuide: StyleGuide {
        get { self[StyleGuideKey.self] }
        set { self[StyleGuideKey.self] = newValue }
    }
}

public struct StyleGuide {
    public var screenWidth: CGFloat = 375
    public var screenEdgePadding: CGFloat = 16
    public var interItemSpacing: CGFloat = 8

    public init(
        screenWidth: CGFloat = 375,
        screenEdgePadding: CGFloat = 16,
        interItemSpacing: CGFloat = 8
    ) {
        self.screenWidth = screenWidth
        self.screenEdgePadding = screenEdgePadding
        self.interItemSpacing = interItemSpacing
    }

    public var singleColumnWidth: CGFloat {
        gridSize(for: 1)
    }

    public var twoColumnsWidth: CGFloat {
        gridSize(for: 2)
    }

    public var threeColumnsWidth: CGFloat {
        gridSize(for: 3)
    }

    public func gridSize(for columns: Int) -> CGFloat {
        assert(columns > 0)
        return (screenWidth - 2 * screenEdgePadding - CGFloat(columns - 1) * interItemSpacing) / CGFloat(columns)
    }
}
