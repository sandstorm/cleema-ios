//
//  Created by Kumpels and Friends on 26.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct GridRow<Content: View>: View {
    var items: IdentifiedArrayOf<DashboardGrid.Item> = []
    var gridSize: CGFloat

    @Environment(\.styleGuide) var styleGuide

    @ViewBuilder
    var itemContent: (DashboardGrid.Item) -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .bottom, spacing: styleGuide.interItemSpacing) {
                ForEach(items) { item in
                    itemContent(item)
                        .frame(
                            height: item.dimension
                                .height(for: gridSize, itemSpacing: styleGuide.interItemSpacing)
                        )
                }
            }
            .frame(
                height: items.height(for: gridSize, itemSpacing: styleGuide.interItemSpacing)
            )
            .padding(.horizontal, styleGuide.screenEdgePadding)
        }
    }
}

extension DashboardGrid.Dimension {
    func height(for gridSize: CGFloat, itemSpacing: CGFloat) -> CGFloat {
        guard gridSize > 0 else { return 0 }
        switch self {
        case .small:
            return gridSize
        case .medium:
            return 1.5 * gridSize + itemSpacing / 2
        case .large:
            return 2 * gridSize + itemSpacing
        }
    }
}

extension Collection where Element == DashboardGrid.Item {
    func height(for gridSize: CGFloat, itemSpacing: CGFloat) -> CGFloat {
        self.max { $0.dimension < $1.dimension }?.dimension.height(for: gridSize, itemSpacing: itemSpacing) ?? 0
    }
}
