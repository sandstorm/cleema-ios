//
//  Created by Kumpels and Friends on 23.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct FavoritesButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color = {
            switch (isEnabled, configuration.isPressed) {
            case (true, false):
                return Color.dimmed
            case (true, true):
                return Color.defaultText.opacity(0.65)
            case (false, _):
                return Color.dimmed.opacity(0.5)
            }
        }()

        HStack {
            configuration.label
                .font(.montserratBold(style: .headline, size: 14))

            Spacer()

            Image(systemName: "chevron.right")
        }
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(backgroundColor)
                .blendMode(configuration.isPressed ? .multiply : .normal)
        }
    }
}

public extension ButtonStyle where Self == FavoritesButtonStyle {
    static var favorites: Self { .init() }
}
