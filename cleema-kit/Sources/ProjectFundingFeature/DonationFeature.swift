//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import Styling
import SwiftUI

public struct Donation: ReducerProtocol {
    public typealias State = Int
    public enum Action: Equatable {
        case restartTapped
    }

    public init() {}

    public func reduce(into state: inout Int, action: Action) -> EffectTask<Action> {
        .none
    }
}

struct DonationView: View {
    let store: StoreOf<Donation>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(
                    L10n.Funding
                        .summary(viewStore.state.formatted(.currency(code: "EUR").precision(.fractionLength(0))))
                )
                .bold()
                .padding(.vertical)

                Button(L10n.Funding.Button.AgainAction.label) {
                    viewStore.send(.restartTapped)
                }
                .buttonStyle(.action)
            }
        }
    }
}

struct DonationView_Previews: PreviewProvider {
    static var previews: some View {
        DonationView(store: .init(initialState: Int.random(in: 1 ... 100), reducer: Donation()))
    }
}
