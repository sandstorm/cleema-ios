//
//  Created by Kumpels and Friends on 25.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct InputTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.white)
            }
    }
}

public extension TextFieldStyle where Self == InputTextFieldStyle {
    static var input: Self { .init() }
}
