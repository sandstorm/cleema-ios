//
//  Created by Kumpels and Friends on 19.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct ActionButtonStyle: ButtonStyle {
    var maxWidth: CGFloat?
    @Environment(\.isEnabled) var isEnabled

    public init(maxWidth: CGFloat? = nil) {
        self.maxWidth = maxWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.montserratBold(style: .headline, size: 14))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 30)
            .frame(maxWidth: maxWidth)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isEnabled ? Color.action : Color.action.opacity(0.5))
                    .blendMode(configuration.isPressed ? .hardLight : .normal)
            }
    }
}

public extension ButtonStyle where Self == ActionButtonStyle {
    static var action: Self { .init() }

    static func action(maxWidth: CGFloat? = nil) -> Self {
        .init(maxWidth: maxWidth)
    }
}
