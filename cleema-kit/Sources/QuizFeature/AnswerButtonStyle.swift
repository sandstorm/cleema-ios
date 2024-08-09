//
//  Created by Kumpels and Friends on 26.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Styling
import SwiftUI

struct AnswerButtonStyle: ButtonStyle {
    var answer: Quiz.Choice
    var isHighlighted: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            Text(answer.index.uppercased())
                .font(.montserratBold(style: .largeTitle, size: 30))
                .frame(maxHeight: .infinity)
                .frame(width: 40)
                .background(configuration.isPressed ? answerIDColor.opacity(0.65) : answerIDColor)

            configuration.label
                .padding(.horizontal, 14)
                .padding(.vertical)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(configuration.isPressed ? answerContentColor.opacity(0.65) : answerContentColor)
        }
        .foregroundColor(.white)
        .frame(minHeight: 88)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    var answerIDColor: Color {
        isHighlighted ? .accent : .answer
    }

    var answerContentColor: Color {
        isHighlighted ? .dimmed : .action
    }
}
