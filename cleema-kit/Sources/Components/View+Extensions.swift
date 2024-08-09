//
//  Created by Kumpels and Friends on 12.09.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

public extension View {
    func reportSize<Tag>(_ tag: Tag.Type, nextValue: @escaping (CGSize) -> Void) -> some View {
        overlay(
            GeometryReader { proxy in
                Color.clear.preference(key: TaggedSizePreference<Tag>.self, value: proxy.size)
            }
        )
        .onPreferenceChange(TaggedSizePreference<Tag>.self) { value in
            value.flatMap(nextValue)
        }
    }
}

private enum FixSizeTag {}

private struct TaggedSizePreference<Tag>: PreferenceKey {
    static var defaultValue: CGSize? {
        nil
    }

    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}
