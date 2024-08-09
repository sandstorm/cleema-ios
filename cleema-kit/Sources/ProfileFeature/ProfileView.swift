//
//  Created by Kumpels and Friends on 03.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ProfileEditFeature
import RegisterUserFeature
import Styling
import SwiftUI
import TrophiesFeature
import UserFavoritesFeature

extension User.Kind {
    var title: String {
        switch self {
        case .local:
            return L10n.AccountType.local
        case let .remote(_, email):
            return L10n.AccountType.server(email)
        }
    }
}

// MARK: - View

public struct ProfileView: View {
    let store: StoreOf<Profile>

    public init(store: StoreOf<Profile>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ProfileDataView(store: store.scope(state: \.profileDataState, action: Profile.Action.profileData))
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .transition(.scale)

                    UserFavoritesView(
                        store: store
                            .scope(state: \.userFavoritesState, action: Profile.Action.userFavorites)
                    )
                    .padding(.horizontal)
                    .disabled(viewStore.isEditingProfile)
                    .padding(.bottom, 12)
                    .saturation(viewStore.isEditingProfile ? 0 : 1)
                    .opacity(viewStore.isEditingProfile ? 0.5 : 1)

                    VStack(alignment: .leading) {
                        Text(L10n.Section.TrophyCase.label)
                            .font(.montserratBold(style: .title, size: 16))
                            .foregroundColor(.accent)

                        TrophiesFeatureView(
                            store: store
                                .scope(state: \.trophiesFeatureState, action: Profile.Action.trophies)
                        )
                        Spacer()

                        VStack(spacing: 16) {
                            if case .remote = viewStore.profileDataState.user?.kind {
                                Button(L10n.Button.Logout.label, role: .destructive) {
                                    viewStore.send(.logoutTapped)
                                }
                            }

                            Button(L10n.Button.RemoveAccount.label, role: .destructive) {
                                viewStore.send(.removeProfileTapped)
                            }
                        }
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.recessedText)
                        .font(.montserrat(style: .body, size: 14))
                    }
                    .padding()
                    .background(Color.defaultText)
                    .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                    .frame(minHeight: 100)
                    .disabled(viewStore.isEditingProfile)
                    .saturation(viewStore.isEditingProfile ? 0 : 1)
                    .opacity(viewStore.isEditingProfile ? 0.5 : 1)
                }
                .foregroundColor(.defaultText)
                .background(Color.accent)
                .alert(store.scope(state: \.alertState), dismiss: Profile.Action.dismissAlert)
                .navigationTitle(L10n.title)
                .navigationBarTitleDisplayMode(.automatic)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !viewStore.isEditingProfile {
                        Button {
                            viewStore.send(.editProfileButtonTapped, animation: .default)
                        } label: {
                            Asset.editProfileButton.image
                        }
                        .animation(nil)
                    }
                }
            }
        }
        .background(Color.defaultText)
        .backport.presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var user = User(
        name: "fakeuser",
        region: .leipzig,
        joinDate: Date.now,
        kind: .remote(password: "yasdf", email: "foo@kf-interactive.com"),
        referralCode: "cleema-coda",
        avatar: .fake(image: .fake(width: 312, height: 312))
    )

    static var previews: some View {
        VStack {
            Text("Preview")
        }
        .sheet(isPresented: .constant(true)) {
            NavigationView {
                ProfileView(
                    store: .init(
                        initialState: .init(),
                        reducer: Profile()
                    )
                )
            }
            .cleemaStyle()
        }
    }
}
