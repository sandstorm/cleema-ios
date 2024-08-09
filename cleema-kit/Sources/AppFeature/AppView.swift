//
//  Created by Kumpels and Friends on 26.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Alerts
import Components
import ComposableArchitecture
import InfoFeature
import Styling
import SwiftUI

public struct AppView: View {
    let store: StoreOf<App>

    @State var width: CGFloat = 0

    public init(store: StoreOf<App>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(get: \.selectedSection, send: App.Action.selectSection)) {
                ForEach(App.Section.allCases) { section in
                    NavigationView {
                        section.content(for: store)
                            .background(ScreenBackgroundView())
                    }
                    .tag(section)
                    .tabItem {
                        Label {
                            Text(section.title)
                        } icon: {
                            section.image
                        }
                    }
                }
            }
            .environment(\.styleGuide, .init(screenWidth: width))
            .task {
                await viewStore.send(.task).finish()
            }
            .sheet(
                unwrapping: viewStore.binding(
                    get: \.destination,
                    send: App.Action.dismissDestination
                ),
                case: /App.Destination.sheet
            ) { $sheetType in
                switch sheetType {
                case let .inviteActivity(invitationURL):
                    ActivityView(activityItems: [invitationURL])
                        .backport.presentationDetents([.medium])
                case .profile:
                    NavigationView {
                        IfLetStore(
                            store.scope(
                                state: \.profileState,
                                action: App.Action.profile
                            )
                        ) {
                            ProfileView(store: $0)
                                .backport.presentationDragIndicator(.visible)
                        }
                    }
                    .backport.presentationDetents([.large])
                case .info:
                    NavigationView {
                        IfLetStore(
                            store.scope(
                                state: \.infoState,
                                action: App.Action.info
                            )
                        ) { InfoDetailView(store: $0).backport.presentationDragIndicator(.visible) }
                    }
                    .backport.presentationDetents([.large])
                }
            }
            .dialog(
                unwrapping: viewStore.binding(
                    get: \.destination,
                    send: App.Action.dismissDestination
                ),
                case: /App.Destination.dialog
            ) { $dialogState in
                dialog(dialogState, viewStore)
            }
        }
        .foregroundColor(.defaultText)
        .reportSize(AppView.self) {
            width = $0.width
        }
        .alert(store.scope(state: \.alertState), dismiss: App.Action.dismissDestination)
    }

    @MainActor
    @ViewBuilder
    private func dialog(_ dialogState: App.DialogState, _ viewStore: ViewStoreOf<App>) -> some View {
        switch dialogState {
        case let .acceptInvitation(user):
            DialogView(
                user: user,
                defaultButton: .init(
                    title: Alerts.L10n.Alert.Invitation.Dismiss.title,
                    action: {
                        viewStore.send(.dismissDestination, animation: .default)
                    }
                )
            )
        case let .trophy(trophy):
            DialogView(
                trophy: trophy,
                defaultButton: .init(
                    title: L10n.Box.NewTrophy.action,
                    action: {
                        viewStore.send(.dismissDestination, animation: .default)
                    }
                )
            )
        case .invite:
            DialogView(
                title: L10n.Box.Invite.title,
                message: L10n.Box.Invite.message,
                defaultButton: .init(title: L10n.Box.Invite.action, action: {
                    viewStore.send(.invitationButtonTapped, animation: .default)
                }),
                closeButton: .init(title: "", action: {
                    viewStore.send(.dismissDestination, animation: .default)
                })
            )
        }
    }
}

extension DialogView where ImageContent == TrophyDialogView {
    init(
        trophy: Trophy,
        defaultButton: DialogButton,
        closeButton: DialogButton? = nil
    ) {
        self.init(
            title: L10n.Box.NewTrophy.title,
            image: {
                TrophyDialogView(trophy: trophy)
            },
            defaultButton: defaultButton,
            closeButton: closeButton
        )
    }
}

extension DialogView where ImageContent == AvatarDialogView {
    init(
        user: SocialUser,
        defaultButton: DialogButton,
        closeButton: DialogButton? = nil
    ) {
        self.init(
            title: L10n.Box.NewFriend.title,
            message: L10n.Box.NewFriend.message(user.username),
            image: {
                AvatarDialogView(avatar: user.avatar)
            },
            defaultButton: defaultButton,
            closeButton: closeButton
        )
    }
}

// MARK: Preview

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(
                    dashboardGridState: .init(),
                    newsState: .init(searchState: .init(region: Region.leipzig.id)),
                    projectsState: .init(selectRegionState: .init(selectedRegion: .pirna)),
                    challengesState: .init(selectRegionState: .init(selectedRegion: .pirna), userRegion: .pirna),
                    marketplaceState: .init(selectRegionState: .init(selectedRegion: .pirna))
                ),
                reducer: App()
            )
        )
        .cleemaStyle()
    }
}

public extension View {
    @MainActor
    func dialog<Value, Content>(
        unwrapping value: Binding<Value?>,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) -> some View
        where Content: View
    {
        overlay(Binding(unwrapping: value).map(content))
    }

    @MainActor
    func dialog<Enum, Case, Content>(
        unwrapping enum: Binding<Enum?>,
        case casePath: CasePath<Enum, Case>,
        @ViewBuilder content: @escaping (Binding<Case>) -> Content
    ) -> some View
        where Content: View
    {
        dialog(unwrapping: `enum`.case(casePath), content: content)
    }
}
