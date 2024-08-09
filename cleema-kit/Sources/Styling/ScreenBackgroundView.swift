//
//  Created by Kumpels and Friends on 09.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public struct ScreenBackgroundView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color.defaultText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Image("backgroundLayer0", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 19, x: 0, y: 2)

                    Image("backgroundLayer1", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 42, x: -10, y: -10)

                    Image("backgroundLayer2", bundle: .module)
                        .resizable()
                        .scaledToFit()

                    Image("backgroundLayer3", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 25)
                        .shadow(radius: 42, x: -10, y: -10)

                    Image("backgroundLayer4", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 38, x: 0, y: -10)
                }
                .overlay {
                    GeometryReader { p in
                        Color.accent
                            .offset(y: p.size.height)
                    }
                }
            }
        }
    }
}

struct ScreenBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenBackgroundView()
    }
}
