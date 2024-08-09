//
//  Created by Kumpels and Friends on 14.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIBackports

public extension Backport where Wrapped == Any {
    struct Flow<Element: Hashable & Identifiable, ElementContent: View>: View {
        var data: [Element]
        var spacing: CGFloat
        var content: (Element) -> ElementContent

        public init(data: [Element], spacing: CGFloat, @ViewBuilder content: @escaping (Element) -> ElementContent) {
            self.data = data
            self.spacing = spacing
            self.content = content
        }

        public var body: some View {
            if #available(iOS 16, macOS 13, *) {
                Components.Flow(spacing: spacing) {
                    ForEach(data) {
                        content($0)
                    }
                }
            } else {
                TagListView(data: data, spacing: spacing) {
                    content($0)
                }
            }
        }
    }
}
