//
//  Created by Kumpels and Friends on 27.09.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func scrollContentBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(.hidden)
        } else {
            modifier(HideTableViewBackgroundModifier())
        }
    }
}

private struct HideTableViewBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
            .onDisappear {
                UITableView.appearance().backgroundColor = .systemGroupedBackground
            }
    }
}
