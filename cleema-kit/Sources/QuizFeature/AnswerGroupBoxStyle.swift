//
//  Created by Kumpels and Friends on 26.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Styling
import SwiftUI

struct AnswerGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
            configuration.content
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .cardShadow()
    }
}
