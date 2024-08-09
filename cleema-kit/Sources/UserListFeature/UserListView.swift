//
//  Created by Kumpels and Friends on 15.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import NukeUI
import Styling
import SwiftUI

public struct UserListView: View {
    let store: StoreOf<UserList>

    public init(store: StoreOf<UserList>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                switch viewStore.status {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case let .content(items, _):
                    List {
                        ForEach(items) { item in
                            let user = item.user
                            Button {
                                viewStore.send(UserList.Action.selectedUser(item))
                            } label: {
                                HStack {
                                    if let avatar = user.avatar {
                                        LazyImage(url: avatar.url) { state in
                                            if let image = state.image {
                                                image
                                                    .resizingMode(.aspectFit)
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                    Text(user.username)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case .noContent:
                    Text(L10n.Content.Empty.label)
                        .font(.montserrat(style: .title, size: 16))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error:
                    Text(L10n.Content.Error.label)
                        .font(.montserratBold(style: .title, size: 16))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .scrollContentBackgroundHidden()
            .task {
                await viewStore.send(.task).finish()
            }
        }
        .background(Color.accent, ignoresSafeAreaEdges: .all)
        .alert(store.scope(state: \.alertState), dismiss: UserList.Action.dismissAlert)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(
            store: .init(
                initialState: .init(socialUserType: .followers),
                reducer: UserList()
            )
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.defaultText)
        .background(Color.accent)
        .cleemaStyle()
    }
}
