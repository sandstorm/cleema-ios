//
//  Created by Kumpels and Friends on 25.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import CreateUserFeature
import Foundation
import RegisterUserFeature
import Styling
import SwiftUI

struct RegistrationPicker: View {
    let store: StoreOf<NewUser>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    if let hint = viewStore.hint {
                        ErrorHintView(message: hint) {
                            viewStore.send(.clearErrorTapped, animation: .default)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Picker(L10n.AccountType.label, selection: viewStore.binding(\.$selection).animation()) {
                    ForEach(NewUser.State.Selection.allCases) { value in
                        Text(value.title).tag(value)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewStore.selection.hint)
                    .font(.montserrat(style: .caption, size: 12))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 6)

                switch viewStore.selection {
                case .local:
                    CreateUserView(
                        store: store
                            .scope(state: \.createUserState, action: NewUser.Action.createUser)
                    )
                case .server:
                    RegisterUserView(
                        store: store
                            .scope(state: \.registerUserState, action: NewUser.Action.registerUser)
                    )
                }

                VStack(spacing: 16) {
                    Button {
                        viewStore.send(.saveTapped, animation: .default)
                    } label: {
                        HStack(spacing: 10) {
                            Text(L10n.Button.save)
                            if viewStore.status == .saving {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                    }
                    .buttonStyle(.action(maxWidth: .infinity))

                    Button {
                        viewStore.send(.loginButtonTapped)
                    } label: {
                        Text(L10n.ExistingAccount.button)
                            .underline()
                            .font(.montserrat(style: .caption, size: 14))
                    }
                }
                .padding()
            }
        }
    }
}
