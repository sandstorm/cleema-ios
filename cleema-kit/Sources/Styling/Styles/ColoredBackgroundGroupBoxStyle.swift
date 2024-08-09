//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct ColoredBackgroundGroupBoxStyle: GroupBoxStyle {
    var backgroundColor: Color
    var foregroundColor: Color

    public init(backgroundColor: Color, foregroundColor: Color) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
