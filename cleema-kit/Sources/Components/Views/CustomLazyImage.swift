//
//  Created by Kumpels and Friends on 23.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import NukeUI
import Styling
import SwiftUI

public struct CustomLazyImage: View {
    var url: URL?
    var placeholderImage: SwiftUI.Image

    public init(url: URL? = nil, placeholderImage: SwiftUI.Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholderImage = placeholderImage
    }

    public var body: some View {
        ZStack {
            ZStack {
                placeholderImage
                    .imageScale(.large)
                    .foregroundColor(.lightGray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.95))

            if let url {
                LazyImage(url: url, resizingMode: .aspectFill)
                    .onCreated { view in
                        view.backgroundColor = .clear
                    }
                    .onDisappear(.lowerPriority)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
