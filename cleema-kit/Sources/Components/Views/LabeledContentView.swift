//
//  Created by Kumpels and Friends on 01.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct LabeledContentView<Label: View, Content: View>: View {
    public var horizontalFixed: Bool
    public var verticalFixed: Bool
    public var label: Label
    public var content: Content

    public init(
        horizontalFixed: Bool = true,
        verticalFixed: Bool = true,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalFixed = horizontalFixed
        self.verticalFixed = verticalFixed
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading) {
            label
                .font(.montserratBold(style: .body, size: 14))

            content
                .font(.montserrat(style: .body, size: 14))
                .fixedSize(horizontal: horizontalFixed, vertical: verticalFixed)
        }
    }
}

public extension LabeledContentView where Label == Text, Content == Text {
    init(horizontalFixed: Bool = true, verticalFixed: Bool = true, _ title: String, value: String) {
        self.init(
            horizontalFixed: horizontalFixed,
            verticalFixed: verticalFixed,
            label: { Text(title) },
            content: { Text(value) }
        )
    }
}

public extension LabeledContentView where Label == Text {
    init(
        horizontalFixed: Bool = true,
        verticalFixed: Bool = true,
        _ title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            horizontalFixed: horizontalFixed,
            verticalFixed: verticalFixed,
            label: { Text(title) },
            content: content
        )
    }
}
