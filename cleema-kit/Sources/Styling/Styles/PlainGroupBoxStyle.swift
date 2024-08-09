//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct PlainGroupBoxStyle: GroupBoxStyle {
    public var padding: CGFloat = 20

    init(padding: CGFloat = 20) {
        self.padding = padding
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.montserratBold(style: .headline, size: 16))
                .padding(.bottom, 4)
            configuration.content
        }
        .padding(padding)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .cardShadow()
    }
}

public extension GroupBoxStyle where Self == PlainGroupBoxStyle {
    static var plain: Self { .init() }

    static func plain(padding: CGFloat) -> Self { .init(padding: padding) }
}
