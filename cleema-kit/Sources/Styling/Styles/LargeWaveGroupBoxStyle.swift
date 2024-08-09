//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

public struct LargeWaveGroupBoxStyle: GroupBoxStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                configuration.label
                    .font(.montserratBold(style: .subheadline, size: 14))
                configuration.content
            }
            .padding(8)
            .zIndex(1)

            Image(decorative: "wave", bundle: .module)
                .resizable()
                .scaledToFit()
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

public extension GroupBoxStyle where Self == LargeWaveGroupBoxStyle {
    static var largeWave: Self { .init() }
}
