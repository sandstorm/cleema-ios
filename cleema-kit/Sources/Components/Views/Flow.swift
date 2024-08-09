//
//  Created by Kumpels and Friends on 27.07.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

#if swift(>=5.7)
import SwiftUI
@available(iOS 16.0, macOS 13.0, *)
public struct Flow: Layout {
    public typealias Cache = [CGSize]

    public init(spacing: CGFloat = 10) {
        self.spacing = spacing
    }

    var spacing: CGFloat

    public func makeCache(subviews: Subviews) -> Cache {
        subviews.map { $0.sizeThatFits(.unspecified) }
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let containerWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = cache // subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, containerWidth: containerWidth).size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let sizes = cache // subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }

    private func layout(sizes: [CGSize], containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }

            result.append(currentPosition)
            currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
            currentPosition.x += spacing
            lineHeight = max(lineHeight, size.height)
        }

        return (result, CGSize(width: maxX, height: currentPosition.y + lineHeight))
    }
}
#endif
