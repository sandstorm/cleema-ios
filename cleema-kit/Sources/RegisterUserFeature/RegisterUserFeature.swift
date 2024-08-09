//
//  Created by Kumpels and Friends on 02.03.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Foundation
import Models
import SelectRegionFeature
import UserClient

public struct RegisterUser: ReducerProtocol {
    public struct State: Equatable {
        @BindingState public var name: String
        @BindingState public var password: String
        @BindingState public var confirmation: String
        @BindingState public var email: String
        @BindingState public var acceptsSurveys = false
        public var selectRegionState: SelectRegion.State
        public var showsPasswordHint = false
        public var referralCode: String?

        public init(
            name: String = "",
            password: String = "",
            confirmation: String = "",
            email: String = "",
            acceptsSurveys: Bool = false,
            selectRegionState: SelectRegion.State = .init(),
            showsPasswordHint: Bool = false,
            referralCode: String? = nil
        ) {
            self.name = name
            self.password = password
            self.confirmation = confirmation
            self.email = email
            self.acceptsSurveys = acceptsSurveys
            self.selectRegionState = selectRegionState
            self.showsPasswordHint = showsPasswordHint
            self.referralCode = referralCode
        }
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case selectRegion(SelectRegion.Action)
        case showPasswordHint
        case dismissPasswordHint
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.selectRegionState, action: /Action.selectRegion, child: SelectRegion.init)

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .selectRegion:
                return .none
            case .showPasswordHint:
                state.showsPasswordHint = true
                return .none
            case .dismissPasswordHint:
                state.showsPasswordHint = false
                return .none
            }
        }
    }
}

import SwiftUI
public struct RegisterUserView: View {
    let store: StoreOf<RegisterUser>

    public init(store: StoreOf<RegisterUser>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    TextField(L10n.Form.Textfield.Name.label, text: viewStore.binding(\.$name))
                        .keyboardType(.alphabet)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.oneTimeCode) // TODO: Revert when a proper solution for auto-fill is found

                    Divider().background(Color.defaultText)

                    TextField(L10n.Form.Textfield.Email.label, text: viewStore.binding(\.$email))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.oneTimeCode) // TODO: Revert when a proper solution for auto-fill is found
                        .keyboardType(.emailAddress)

                    Divider().background(Color.defaultText)

                    HStack {
                        TogglableSecureTextField(
                            label: L10n.Form.Textfield.Password.label,
                            text: viewStore.binding(\.$password).animation(.default),
                            buttonColor: .lightGray
                        )
                        .textContentType(.oneTimeCode) // TODO: Revert when a proper solution for auto-fill is found

                        Button {
                            viewStore.send(.showPasswordHint)
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.lightGray)
                        }
                        .alwaysPopover(
                            isPresented: viewStore
                                .binding(get: \.showsPasswordHint, send: RegisterUser.Action.dismissPasswordHint)
                        ) {
                            Text(Components.L10n.Form.Password.hint)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.montserrat(style: .caption, size: 12))
                                .foregroundColor(.defaultText)
                                .frame(maxWidth: 240, alignment: .leading)
                                .padding()
                        }
                    }

                    Divider().background(Color.defaultText)

                    if !viewStore.password.isEmpty {
                        HStack {
                            TogglableSecureTextField(
                                label: L10n.Form.Textfield.PasswordConfirm.label,
                                text: viewStore.binding(\.$confirmation),
                                buttonColor: .lightGray
                            )
                            .textContentType(.oneTimeCode) // TODO: Revert when a proper solution for auto-fill is found
                        }

                        Divider().background(Color.defaultText)
                    }

                    SelectRegionView(
                        store: store.scope(state: \.selectRegionState, action: RegisterUser.Action.selectRegion),
                        valuePrefix: nil,
                        horizontalPadding: 0
                    )
                    .disabled(viewStore.selectRegionState.regions.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                Toggle(L10n.Form.Toggle.AllowSurveys.label, isOn: viewStore.binding(\.$acceptsSurveys))
                    .toggleStyle(.checkbox())

                VStack(alignment: .leading) {
                    Link(L10n.Link.Privacy.label, destination: URL(string: L10n.Link.Privacy.url)!)
                    Link(L10n.Link.LegalNotice.label, destination: URL(string: L10n.Link.LegalNotice.url)!)
                }
                .foregroundColor(.action)
            }
        }
    }
}

import Styling
struct RegisterUserFeature_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                RegisterUserView(
                    store: .init(initialState: .init(), reducer: RegisterUser())
                )
                .padding()
            }
            .ignoresSafeArea(edges: .bottom)
            .background(Color.accent, ignoresSafeAreaEdges: .all)
        }
        .cleemaStyle()
    }
}
