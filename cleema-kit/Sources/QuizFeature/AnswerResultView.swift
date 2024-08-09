//
//  Created by Kumpels and Friends on 12.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import SwiftUI

struct AnswerResultView<SubTitle: View>: View {
    var title: String
    var message: String
    @ViewBuilder var subTitle: SubTitle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).bold()
            subTitle
            Text(message)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension AnswerResultView where SubTitle == Text {
    init(title: String, message: String, content: String) {
        self.init(title: title, message: message) {
            Text(content)
        }
    }
}

extension AnswerResultView where SubTitle == EmptyView {
    init(title: String, message: String) {
        self.init(title: title, message: message) {}
    }
}

struct AnswerResultView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerResultView(title: "Hurrayyy", message: "Come back tomorrow!") {
            Text("Your current score is") + Text(" \(12) ")
                .bold() + Text("Points. Your current streak is") + Text(" \(3) ").bold() + Text("days in a row.")
        }
    }
}
