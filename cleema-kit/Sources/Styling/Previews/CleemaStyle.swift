//
//  Created by Kumpels and Friends on 28.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

#if targetEnvironment(simulator)
struct CleemaStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        let _ = Styling.configureApp()
        content
            .groupBoxStyle(.plain)
            .foregroundColor(.defaultText)
    }
}

public extension View {
    func cleemaStyle() -> some View {
        modifier(CleemaStyleModifier())
    }
}
#else
public extension View {
    func cleemaStyle() -> some View {
        self
    }
}
#endif
