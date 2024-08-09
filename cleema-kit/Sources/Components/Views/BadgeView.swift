//
//  Created by Kumpels and Friends on 18.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Styling
import SwiftUI

public struct BadgeView: View {
    var text: String
    var color: Color

    @State private var textSize: CGSize = .zero

    @ScaledMetric(relativeTo: .largeTitle) private var padding: CGFloat = 26

    public init(text: String, color: Color = .action) {
        self.text = text
        self.color = color
    }

    private enum ID {}

    public var body: some View {
        if !text.isEmpty {
            ZStack(alignment: .center) {
                Image("badgeOverlay", bundle: Styling.bundle)
                    .renderingMode(.template)
                    .resizable(capInsets: .init(top: 18, leading: 18, bottom: 18, trailing: 18))
                    .foregroundColor(color)
                    .frame(width: max(37, textSize.width + padding), height: max(37, textSize.height + padding))

                Text(text)
                    .font(.montserrat(style: .caption, size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .fixedSize()
                    .reportSize(ID.self) {
                        textSize = $0
                    }
                    .offset(x: 5, y: -5)
            }
        }
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BadgeView(text: "2", color: .red)

            BadgeView(text: "42", color: .red)

            BadgeView(text: "Tipp", color: .red)

            BadgeView(text: "News", color: .red)
                .dynamicTypeSize(.accessibility5)
        }
        .cleemaStyle()
    }
}
