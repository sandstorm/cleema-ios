//
//  Created by Kumpels and Friends on 01.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct SearchTextFieldStyle: TextFieldStyle {
    @FocusState var isFocused

    public func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            configuration
                .font(.montserrat(style: .body, size: 14))
                .foregroundColor(.textInput)
            Image(systemName: "magnifyingglass")
                .foregroundColor(.action)
        }
        .focused($isFocused)
        .padding(12)
        .background(in: Capsule())
        .onTapGesture {
            isFocused = true
        }
    }
}

public extension TextFieldStyle where Self == SearchTextFieldStyle {
    static var search: Self { .init() }
}
