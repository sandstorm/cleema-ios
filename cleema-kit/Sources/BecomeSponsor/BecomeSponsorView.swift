//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct BecomeSponsorView: View {
    let store: StoreOf<BecomeSponsor>

    public init(store: StoreOf<BecomeSponsor>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    switch viewStore.step {
                    case .selectPackage:
                        SelectPackageView(store: store)
                    case .enterData:
                        EnterDataView(store: store)
                        Spacer()
                    case .confirm:
                        ConfirmView(store: store)
                        Spacer()
                    case .thanks:
                        ThanksView(store: store)
                        Spacer()
                    }
                }
                .padding()
                .transition(.move(edge: .leading))
                .animation(.easeInOut, value: viewStore.step)
                .groupBoxStyle(.plain(padding: 0))
                .background(Color.accent)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            viewStore.send(.dismissSheet)
                        }
                    }
                }
            }
        }
    }
}

struct BecomeSponsorView_Previews: PreviewProvider {
    static var previews: some View {
        BecomeSponsorView(store: .init(initialState: .init(), reducer: BecomeSponsor()))
    }
}
