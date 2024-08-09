//
//  Created by Kumpels and Friends on 01.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct TagListView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    var data: Data
    var spacing: CGFloat
    var alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    @State private var availableWidth: CGFloat = 10

    public init(
        data: Data,
        spacing: CGFloat = 8,
        alignment: HorizontalAlignment = .leading,
        content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .reportSize(HeightID.self) { size in
                    availableWidth = size.width
                }

            FlexibleView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }

    private enum HeightID {}
}

private struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var sizes: [Data.Element: CGSize] = [:]

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .reportSize(FlexibleView<Data, Content>.self) { size in
                                sizes[element] = size
                            }
                    }
                }
            }
        }
    }

    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth

        for element in data {
            let elementSize = sizes[element, default: CGSize(width: availableWidth, height: 1)]

            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }

            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }

        return rows
    }
}

struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        TagListView(data: ["world", "tags", "change", "everything", "once", "climate", "foo", "bar"]) {
            Text($0)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Capsule().stroke())
        }
    }
}
