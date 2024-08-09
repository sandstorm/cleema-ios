//
//  Created by Kumpels and Friends on 17.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ThanksView: View {
    let store: StoreOf<BecomeSponsor>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vielen Dank")
                        .font(.montserratBold(style: .title, size: 16))

                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.defaultText)
                        Text("Wir wurden benachrichtigt und melden uns bei Dir.")
                    }
                    .padding(.vertical)

                    Button("Schließen") {
                        viewStore.send(.dismissSheet)
                    }
                    .buttonStyle(.action(maxWidth: .infinity))
                }
                .padding(20)
            }
        }
    }
}
