//
//  Created by Kumpels and Friends on 05.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation

public struct ProgressCounter: ReducerProtocol {
    public struct State: Equatable {
        @BindingState
        public var count: UInt

        public init(count: UInt = 1) {
            self.count = count
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}

import SwiftUI

public struct ProgressFeatureView: View {
    let store: StoreOf<ProgressCounter>

    public init(store: StoreOf<ProgressCounter>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Stepper(
                L10n.Form.Section.Goal.Picker.GoalType.Progress.Stepper.times(Int(viewStore.count)),
                value: viewStore.binding(\.$count), in: 1 ... 999
            )
        }
    }
}

struct ProgressFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressFeatureView(store: .init(initialState: .init(count: 42), reducer: ProgressCounter()))
    }
}
