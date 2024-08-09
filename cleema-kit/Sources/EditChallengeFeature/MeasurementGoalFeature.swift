//
//  Created by Kumpels and Friends on 05.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models

public struct MeasurementGoal: ReducerProtocol {
    public struct State: Equatable {
        @BindingState
        public var count: UInt

        @BindingState
        public var unit: Models.Unit
        public var availableUnits: [Models.Unit]

        public init(count: UInt, unit: Models.Unit? = nil, availableUnits: [Models.Unit] = Models.Unit.allCases) {
            self.count = count
            self.unit = unit ?? availableUnits[0]
            self.availableUnits = availableUnits
        }
    }

    public enum Action: Equatable, BindableAction {
        case unitChanged(Models.Unit)
        case binding(BindingAction<MeasurementGoal.State>)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .unitChanged(unit):
                state.unit = unit
                return .none
            case .binding: return .none
            }
        }
    }
}

extension Dimension: Identifiable {
    public var id: Dimension {
        self
    }
}

import SwiftUI

public struct MeasurementGoalView: View {
    let store: StoreOf<MeasurementGoal>

    public init(store: StoreOf<MeasurementGoal>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Picker(
                    L10n.Form.Section.Goal.Picker.GoalType.Measurement.unit,
                    selection: viewStore.binding(\.$unit)
                ) {
                    ForEach(viewStore.availableUnits) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                Stepper(
                    "\(viewStore.count) \(viewStore.unit.title)",
                    value: viewStore.binding(\.$count),
                    in: 1 ... 999
                )
            }
        }
    }
}

struct MeasurementGoalView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            MeasurementGoalView(store: .init(
                initialState: .init(count: 42, unit: nil),
                reducer: MeasurementGoal()
            ))
        }
    }
}
