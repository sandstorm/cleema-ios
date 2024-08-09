//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

public struct Amount: ReducerProtocol {
    public struct State: Hashable {
        public enum Kind: Int, Equatable {
            case preset
            case custom
        }

        @BindingState
        public var amount: Int
        public var kind: Kind

        init(amount: Int, kind: Kind) {
            self.amount = amount
            self.kind = kind
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<Amount.State>)
        case selection(newValue: Amount.State)
        case supportTapped
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case let .selection(newValue):
                state = newValue
                return .none
            case .binding:
                state.kind = .custom
                return .none
            case .supportTapped:
                return .none
            }
        }
    }
}

public extension Amount.State {
    static let five: Self = .init(amount: 5, kind: .preset)
    static let ten: Self = .init(amount: 10, kind: .preset)
    static let fifteen: Self = .init(amount: 15, kind: .preset)
    static let twenty: Self = .init(amount: 20, kind: .preset)
    static func custom(_ amount: Int = 0) -> Self {
        .init(amount: amount, kind: .custom)
    }
}

struct AmountView: View {
    let store: StoreOf<Amount>
    let presets: [Amount.State] = [.five, .ten, .fifteen, .twenty, .custom(0)]

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Picker(
                    L10n.Funding.Picker.Amount.label,
                    selection: viewStore.binding(send: Amount.Action.selection(newValue:))
                ) {
                    ForEach(presets, id: \.self) { preset in
                        switch preset.kind {
                        case .preset:
                            Text(preset.amount.formatted(.currency(code: "EUR").precision(.fractionLength(0))))
                                .tag(preset)
                        case .custom:
                            Text(L10n.Funding.Picker.Amount.Value.Custom.label)
                                .tag(preset)
                        }
                    }
                }
                .pickerStyle(.segmented)

                if viewStore.state.kind == .custom {
                    TextField(
                        L10n.Funding.Textfield.Amount.Custom.label,
                        value: viewStore.binding(\.$amount),
                        format: .currency(code: "EUR").precision(.fractionLength(0))
                    )
                    .onSubmit {
                        viewStore.send(.selection(newValue: .custom(viewStore.amount)))
                    }
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .textFieldStyle(.roundedBorder)
                }

                Button(L10n.Funding.Button.Action.label) {
                    viewStore.send(.supportTapped)
                }
                .buttonStyle(.action)
                .disabled(viewStore.state.amount <= 0)
            }
            .padding()
        }
    }
}

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        AmountView(
            store: .init(
                initialState: .custom(42),
                reducer: Amount()
            )
        )
    }
}
