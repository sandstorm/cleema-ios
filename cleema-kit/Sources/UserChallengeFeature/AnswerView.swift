//
//  Created by Kumpels and Friends on 05.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import ConfettiSwiftUI
import SwiftUI

extension RelativeDateTimeFormatter {
    static let pendingDate: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .spellOut
        return formatter
    }()
}

struct AnswerView: View {
    let store: Store<AnswerState, UserChallenge.Action>

    @State private var counter = 0

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state {
            case let .upcoming(comps): // TODO: Change associated value to Int
                Text(L10n.Form.State.Upcoming.summary(comps.day ?? 0))
            case let .pending(_, comps):
                VStack(spacing: 24) {
                    Text(
                        L10n.Form.State.Pending.summary(
                            RelativeDateTimeFormatter.pendingDate.localizedString(from: comps)
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    buttons(viewStore)
                }

            case let .pendingWeekly(pendingIndex, currentWeekIndex):
                VStack(spacing: 24) {
                    Text(
                        pendingIndex == currentWeekIndex ? L10n.pendingThisWeek : L10n.pendingLastWeek
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    buttons(viewStore)
                }
            case .answered:
                Text(L10n.Form.State.Answered.summary)
            case .expired:
                Text(L10n.Form.State.Expired.summary)
            }
        }
    }

    @ViewBuilder
    func buttons(_ viewStore: ViewStore<AnswerState, UserChallenge.Action>) -> some View {
        HStack(spacing: 40) {
            Button {
                viewStore.send(.failedTapped, animation: .default)
            } label: {
                Image("failButton", bundle: .module)
            }
            .foregroundColor(.red)

            Button {
                viewStore.send(.succeededTapped, animation: .default)
                counter += 1
            } label: {
                Image("successButton", bundle: .module)
            }
            .confettiCannon(
                counter: $counter,
                num: 50,
                confettis: [.shape(.circle)],
                colors: [.action, .answer, .defaultText, .selfChallenge],
                openingAngle: Angle(degrees: 0),
                closingAngle: Angle(degrees: 360),
                radius: 200
            )
        }
    }
}

struct AnswerView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerView(
            store: .init(
                initialState: .pending(pendingIndex: 1, dateComponents: .init(day: -4)),
                reducer: EmptyReducer<AnswerState, UserChallenge.Action>()
            )
        )
        .padding()
    }
}
