//
//  Created by Kumpels and Friends on 28.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import RegionsClient
import SelectRegionFeature
import Styling
import SwiftUI
import UserClient

public struct CreateUser: ReducerProtocol {
    public struct State: Equatable {
        @BindingState public var name = ""
        public var selectRegionState: SelectRegion.State
        @BindingState public var acceptsSurveys = false

        public init(
            name: String = "",
            selectRegionState: SelectRegion.State = .init(),
            acceptsSurveys: Bool = false
        ) {
            self.selectRegionState = selectRegionState
            self.name = name
            self.acceptsSurveys = acceptsSurveys
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case selectRegion(SelectRegion.Action)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(
            state: \.selectRegionState,
            action: /Action.selectRegion
        ) {
            SelectRegion()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .selectRegion:
                return .none
            }
        }
    }
}

// MARK: - View

public struct CreateUserView: View {
    let store: StoreOf<CreateUser>

    public init(store: StoreOf<CreateUser>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 46) {
                VStack(alignment: .leading, spacing: 16) {
                    TextField(L10n.Username.label, text: viewStore.binding(\.$name))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.input)
                        .textContentType(.username)

                    SelectRegionView(
                        store: store.scope(
                            state: \.selectRegionState,
                            action: CreateUser.Action.selectRegion
                        ),
                        valuePrefix: nil,
                        horizontalPadding: 16
                    )
                    .disabled(viewStore.selectRegionState.regions.isEmpty)

                    Toggle(L10n.Survey.Toggle.label, isOn: viewStore.binding(\.$acceptsSurveys))
                        .toggleStyle(.checkbox())
                }
            }
        }
    }
}

// MARK: - Preview

struct CreateUserViewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateUserView(
                store: .init(
                    initialState: .init(),
                    reducer: CreateUser()
                )
            )
        }
    }
}
