//
//  Created by Kumpels and Friends on 22.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct CardShadowModifier: ViewModifier {
    public static var shadowBottomSpacing = 28.0
    public func body(content: Content) -> some View {
        content
            .background(
                Color.white
                    .padding(16)
                    .offset(y: 10)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 12)
            )
    }
}

public extension View {
    func cardShadow() -> some View {
        modifier(CardShadowModifier())
    }
}

public struct CircleShadowModifier: ViewModifier {
    var isVisible: Bool
    public func body(content: Content) -> some View {
        content
            .background {
                Circle()
                    .foregroundColor(isVisible ? Color.white : .clear)
                    .padding(16)
                    .offset(y: 10)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 12)
            }
    }
}

public extension View {
    func circleShadow(isVisible: Bool) -> some View {
        modifier(CircleShadowModifier(isVisible: isVisible))
    }
}
