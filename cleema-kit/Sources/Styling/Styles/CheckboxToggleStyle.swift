//
//  Created by Kumpels and Friends on 25.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

public struct CheckboxToggleStyle: ToggleStyle {
    public init(checkmarkSize: CGFloat = 24) {
        self.checkmarkSize = checkmarkSize
    }

    var checkmarkSize: CGFloat = 24
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(
                    systemName: configuration.isOn
                        ? "checkmark.square.fill"
                        : "square"
                )
                .resizable()
                .frame(width: checkmarkSize, height: checkmarkSize)
            }
        }
        .buttonStyle(.borderless)
    }
}

public extension ToggleStyle where Self == CheckboxToggleStyle {
    static func checkbox(checkmarkSize: CGFloat = 24) -> Self {
        .init(checkmarkSize: checkmarkSize)
    }
}
