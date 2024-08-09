//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import CreateUserFeature
import RegisterUserFeature
import Styling
import SwiftUI

public struct NewUserView: View {
    let store: StoreOf<NewUser>

    public init(store: StoreOf<NewUser>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 24) {
                        VStack(spacing: 24) {
                            VStack(spacing: 10) {
                                Text(L10n.Welcome.title)
                                Styling.cleemaLogo
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 63)
                            }
                            Text(L10n.Welcome.Hint.createUser)
                                .bold()
                        }

                        Text(L10n.AccountType.description)
                            .font(.caption)
                            .multilineTextAlignment(.center)

                        VStack {
                            if case let .pendingConfirmation(credentials) = viewStore.status {
                                AccountConfirmationView(email: credentials.email) {
                                    viewStore.send(.resetTapped, animation: .default)
                                }
                            } else {
                                RegistrationPicker(store: store)
                            }
                        }
                    }
                    .padding()

                    Asset.onboardingWave.image
                        .resizable()
                        .scaledToFit()
                        .allowsHitTesting(false)
                        .overlay(
                            Color.dimmed
                                .frame(height: 768)
                                .frame(maxWidth: .infinity)
                                .offset(y: 768),
                            alignment: .bottom
                        )
                }
                .foregroundColor(.defaultText)
            }
            .backport.scrollDismissesKeyboard(.immediately)
        }
        .navigationBarHidden(true)
        .background(Color.accent)
    }
}

extension NewUser.State.Selection {
    var hint: String {
        switch self {
        case .local:
            return L10n.AccountType.Local.hint
        case .server:
            return L10n.AccountType.Server.hint
        }
    }
}

struct NewUserView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewUserView(store: .init(initialState: .init(), reducer: NewUser()))
        }
        .cleemaStyle()
        .previewDisplayName("Local Registration")

        NavigationView {
            NewUserView(store: .init(initialState: .init(selection: .server), reducer: NewUser()))
        }
        .cleemaStyle()
        .previewDisplayName("Remote Registration")

        NavigationView {
            NewUserView(store: .init(
                initialState: .init(status: .pendingConfirmation(Credentials(
                    username: "username",
                    password: "password",
                    email: "mail@cleema.app"
                ))),
                reducer: NewUser()
            ))
        }
        .cleemaStyle()
        .previewDisplayName("Account Confirmation")
    }
}
