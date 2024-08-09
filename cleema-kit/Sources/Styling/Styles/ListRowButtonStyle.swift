//
//  Created by Kumpels and Friends on 01.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct ListRowButtonStyle: ButtonStyle {
    public func makeBody(configuration: ListRowButtonStyle.Configuration) -> some View {
        configuration.label
            .saturation(configuration.isPressed ? 1.1 : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
    }
}

public extension ButtonStyle where Self == ListRowButtonStyle {
    static var listRow: Self { .init() }
}
