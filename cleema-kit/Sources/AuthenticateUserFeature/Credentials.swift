//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Foundation

public struct Credentials: ReducerProtocol {
    public struct State: Equatable {
        @BindingState
        public var name: String
        @BindingState
        public var password: String

        public init(name: String, password: String) {
            self.name = name
            self.password = password
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { _, action in
            .none
        }
    }
}

extension Credentials.State {
    var isComplete: Bool {
        !name.isEmpty && !password.isEmpty
    }
}

public extension Credentials.State {
    static let empty: Self = .init(name: "", password: "")
}

import SwiftUI

struct CredentialsView: View {
    let store: StoreOf<Credentials>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                TextField(L10n.Form.Credentials.Username.label, text: viewStore.binding(\.$name))
                    .autocorrectionDisabled(true)
                    .textContentType(.username)

                TogglableSecureTextField(
                    label: L10n.Form.Credentials.Password.label,
                    text: viewStore.binding(\.$password).animation(.default),
                    buttonColor: .lightGray,
                    buttonTrailingPadding: 8
                )
                .textContentType(.password)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white)
                }
            }
            .textFieldStyle(.input)
            .textInputAutocapitalization(.never)
        }
    }
}

struct CredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            CredentialsView(
                store: .init(
                    initialState: .init(name: "", password: ""),
                    reducer: Credentials()
                )
            )
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accent)
        .cleemaStyle()
    }
}
