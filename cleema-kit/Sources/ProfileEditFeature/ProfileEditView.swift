//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//
import Components
import ComposableArchitecture
import Foundation
import NukeUI
import SelectAvatarFeature
import SelectRegionFeature
import Styling
import SwiftUI
import SwiftUINavigation

public struct ProfileEditView: View {
    let store: StoreOf<ProfileEdit>

    public init(store: StoreOf<ProfileEdit>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content(viewStore)
                .sheet(
                    isPresented: viewStore.binding(
                        get: { $0.selectAvatarState != nil },
                        send: ProfileEdit.Action.dismissSelectAvatarSheet
                    )
                ) {
                    IfLetStore(
                        store.scope(state: \.selectAvatarState, action: ProfileEdit.Action.selectAvatar),
                        then: SelectAvatarView.init
                    )
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if viewStore.status != .saving {
                            Button {
                                viewStore.send(.cancelButtonTapped, animation: .default)
                            } label: {
                                Text(L10n.Form.Action.Cancel.label)
                            }
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if viewStore.status != .saving {
                            Button {
                                viewStore.send(.saveButtonTapped, animation: .default)
                            } label: {
                                Text(L10n.Form.Action.Submit.label)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewStore.isSaving)
                .saturation(viewStore.isSaving ? 0 : 1)
                .brightness(viewStore.isSaving ? 0.25 : 0)
        }
    }

    @MainActor
    @ViewBuilder
    func avatarButton(_ viewStore: ViewStoreOf<ProfileEdit>) -> some View {
        Button {
            viewStore.send(.selectAvatarTapped)
        } label: {
            ZStack {
                if let avatar = viewStore.editedUser.avatar {
                    LazyImage(url: avatar.image.url) { state in
                        if let image = state.image {
                            image
                                .resizingMode(.aspectFit)
                        }
                    }
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .font(.largeTitle)
                }

                Image(systemName: "questionmark")
                    .font(.largeTitle.bold())
                    .blendMode(.plusLighter)
                    .padding()
            }
            .frame(width: 104, height: 104)
        }
    }

    @MainActor
    @ViewBuilder
    func content(_ viewStore: ViewStoreOf<ProfileEdit>) -> some View {
        if case .local = viewStore.originalUser.kind {
            localUserContent(viewStore)
        } else {
            remoteUserContent(viewStore)
        }
    }

    @MainActor
    @ViewBuilder
    func remoteUserContent(_ viewStore: ViewStoreOf<ProfileEdit>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let hint = viewStore.status.hint {
                ErrorHintView(message: hint) {
                    viewStore.send(.clearErrorTapped, animation: .default)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 24) {
                    avatarButton(viewStore)

                    VStack(alignment: .leading, spacing: 16) {
                        TextField(L10n.Form.Textfield.Name.label, text: viewStore.binding(\.$editedUser.name))
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .textContentType(.username)

                        Divider().background(Color.defaultText)

                        SelectRegionView(
                            store: store.scope(state: \.selectRegionState, action: ProfileEdit.Action.selectRegion),
                            valuePrefix: nil,
                            horizontalPadding: 0
                        )
                        .disabled(viewStore.selectRegionState.regions.isEmpty)
                    }
                    .padding(.top)
                }
                .padding(.bottom, 6)

                TextField(L10n.Form.Textfield.Email.label, text: viewStore.binding(\.$editedUser.email))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)

                Divider().background(Color.defaultText)

                HStack {
                    SecureField(
                        L10n.Form.Textfield.Password.label,
                        text: viewStore.binding(\.$editedUser.password).animation()
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.newPassword)

                    Button(action: { viewStore.send(.showPasswordHint) }) {
                        Image(systemName: "info.circle")
                    }
                    .alwaysPopover(
                        isPresented: viewStore
                            .binding(get: \.showsPasswordHint, send: ProfileEdit.Action.dismissPasswordHint)
                    ) {
                        Text(Components.L10n.Form.Password.hint)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.montserrat(style: .caption, size: 12))
                            .foregroundColor(.defaultText)
                            .frame(maxWidth: 240, alignment: .leading)
                            .padding()
                    }
                }

                if viewStore.editedUser.showsPasswordConfirmationField {
                    Divider().background(Color.defaultText)

                    SecureField(
                        L10n.Form.Textfield.PasswordConfirm.label,
                        text: viewStore.binding(\.$editedUser.passwordConfirmation)
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.newPassword)

                    Divider().background(Color.defaultText)

                    Text(L10n.Form.OldPassword.headline)
                        .font(.montserrat(style: .caption, size: 12))
                        .foregroundColor(.green)

                    SecureField(
                        L10n.Form.Textfield.OldPassword.label,
                        text: viewStore.binding(\.$editedUser.oldPassword)
                    )
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)

                    Divider().background(Color.defaultText)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background {
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .cardShadow()

            Toggle(L10n.Form.Toggle.AllowSurveys.label, isOn: viewStore.binding(\.$editedUser.acceptsSurveys))
                .toggleStyle(.checkbox())
        }
    }

    @MainActor
    @ViewBuilder
    func localUserContent(_ viewStore: ViewStoreOf<ProfileEdit>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let hint = viewStore.status.hint {
                ErrorHintView(message: hint) {
                    viewStore.send(.clearErrorTapped, animation: .default)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 24) {
                    avatarButton(viewStore)

                    VStack(alignment: .leading, spacing: 16) {
                        TextField(L10n.Form.Textfield.Name.label, text: viewStore.binding(\.$editedUser.name))
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .textContentType(.username)

                        Divider().background(Color.defaultText)

                        SelectRegionView(
                            store: store.scope(state: \.selectRegionState, action: ProfileEdit.Action.selectRegion),
                            valuePrefix: nil,
                            horizontalPadding: 0
                        )
                        .disabled(viewStore.selectRegionState.regions.isEmpty)
                    }
                    .padding(.top)
                }
                .padding(.bottom, 6)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background {
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .cardShadow()

            Toggle(L10n.Form.Toggle.AllowSurveys.label, isOn: viewStore.binding(\.$editedUser.acceptsSurveys))
                .toggleStyle(.checkbox())
        }
    }
}

public struct ProfileEditView_Preview: PreviewProvider {
    public static var previews: some View {
        let remoteUser = User(
            id: .init(UUID()),
            name: "Bernd",
            region: .leipzig,
            joinDate: .distantPast,
            kind: .remote(password: "12345678", email: "bernd@test.de"),
            referralCode: "00000000-0000-0000-0000",
            avatar: .fake()
        )

        NavigationView {
            ProfileEditView(
                store: .init(initialState: .init(user: remoteUser), reducer: ProfileEdit())
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.accent, ignoresSafeAreaEdges: .all)
        }
        .cleemaStyle()
        .previewDisplayName("Remote user")

        let localUser = User(
            id: .init(UUID()),
            name: "Bernd",
            region: .leipzig,
            joinDate: .distantPast,
            kind: .local,
            referralCode: "00000000-0000-0000-0000"
        )

        NavigationView {
            ProfileEditView(
                store: .init(initialState: .init(user: localUser), reducer: ProfileEdit())
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.accent, ignoresSafeAreaEdges: .all)
        }
        .cleemaStyle()
        .previewDisplayName("Local user")
    }
}
