//
//  Created by Kumpels and Friends on 06.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Models
import NukeUI
import Styling
import SwiftUI
import SwiftUINavigation
import UserListFeature

struct ProfileUserView: View {
    let store: StoreOf<ProfileUser>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .top, spacing: 22) {
                AvatarView(avatar: viewStore.user?.avatar, isSupporter: viewStore.user?.isSupporter ?? false)

                UserMetadataView(store: store)
                    .sheet(
                        isPresented: viewStore.binding(
                            get: { $0.userListState != nil },
                            send: ProfileUser.Action.dismissUserList
                        )
                    ) {
                        IfLetStore(
                            store
                                .scope(state: \.userListState, action: ProfileUser.Action.userList)
                        ) { store in
                            WithViewStore(store) { userListViewStore in
                                NavigationView {
                                    UserListView(store: store)
                                        .navigationTitle(userListViewStore.socialUserType.title)
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Button(L10n.Action.Done.label) {
                                                    viewStore.send(.dismissUserList)
                                                }
                                            }
                                        }
                                }
                                .backport.presentationDragIndicator(.visible)
                            }
                        }
                    }
            }
            .task {
                await viewStore.send(.task).finish()
            }
            .alert(store.scope(state: \.alertState), dismiss: ProfileUser.Action.dismissAlert)
            .sheet(
                unwrapping: viewStore.binding(
                    get: \.invitationURL,
                    send: ProfileUser.Action.dismissActivitySheet
                )
            ) { $invitationURL in
                ActivityView(activityItems: [invitationURL])
                    .backport.presentationDetents([.medium])
            }
        }
    }
}

struct ProfileUserView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileUserView(
            store: .init(
                initialState: .init(),
                reducer: ProfileUser()
            )
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.defaultText)
        .background(Color.accent)
        .cleemaStyle()
    }
}
