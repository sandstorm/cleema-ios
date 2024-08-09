//
//  Created by Kumpels and Friends on 15.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Models
import SwiftUI

public struct UserProgressesView: View {
    private let store: StoreOf<UserProgresses>

    public init(store: StoreOf<UserProgresses>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                switch viewStore.status {
                case .loading, .empty:
                    EmptyView()
                case let .content(userProgresses):
                    Divider()
                        .padding(.top, 32)

                    UserProgressList(userProgresses: userProgresses, maxAllowedAnswers: viewStore.maxAllowedAnswers)
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
    }
}

struct UserProgressList: View {
    var userProgresses: IdentifiedArrayOf<UserProgress>
    var maxAllowedAnswers: Int

    var body: some View {
        Text(L10n.headline)
            .font(.montserratBold(style: .headline, size: 14))

        ForEach(userProgresses) { userProgress in
            UserProgressView(userProgress: userProgress, maxAllowedAnswers: maxAllowedAnswers)
        }
    }
}

struct UserProgressesView_Previews: PreviewProvider {
    static var previews: some View {
        UserProgressesView(
            store: .init(
                initialState: .init(
                    userProgresses: [
                        .init(totalAnswers: 10, succeededAnswers: 5, user: .fake()),
                        .init(totalAnswers: 10, succeededAnswers: 2, user: .fake()),
                        .init(totalAnswers: 10, succeededAnswers: 8, user: .fake(avatar: nil))
                    ],
                    maxAllowedAnswers: 10
                ),
                reducer: UserProgresses()
            )
        )
        .padding()
        .cleemaStyle()
    }
}
