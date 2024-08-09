//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import MarkdownUI
import SwiftUI

struct AccountConfirmationView: View {
    var email: String
    var onResetTapped: () -> Void

    var body: some View {
        GroupBox {
            VStack(spacing: 24) {
                Markdown(L10n.Account.Confirmation.text(email))
                    .multilineTextAlignment(.center)

                Button(L10n.Account.Confirmation.resetButton) {
                    onResetTapped()
                }
                .buttonStyle(.action(maxWidth: .infinity))
            }
        }
    }
}

struct AccountConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AccountConfirmationView(email: "hi@there.com") {}
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent)
        .cleemaStyle()
    }
}
