//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import NukeUI
import Styling
import SwiftUI

public struct InviteUsersToChallengeView: View {
    let store: StoreOf<InviteUsersToChallenge>

    public init(store: StoreOf<InviteUsersToChallenge>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                switch viewStore.state {
                case .loading:
                    ProgressView()
                case let .content(followers, selection):
                    VStack(alignment: .leading, spacing: 0) {
                        Text(L10n.InviteUsers.title)
                            .font(.montserratBold(style: .title, size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text(L10n.InviteUsers.message)
                            .font(.montserrat(style: .title, size: 14))
                            .padding(.horizontal)
                            .padding(.top)
                        List {
                            ForEach(followers) { item in
                                Button {
                                    viewStore.send(.toggleSelectionTapped(item.id))
                                } label: {
                                    HStack {
                                        if let avatar = item.avatar {
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
                                        Text(item.username)
                                        Spacer()
                                        if selection.contains(item.id) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    }
                case .noContent:
                    Text(L10n.InviteUsers.Empty.text)
                case .error:
                    Text("An error occurred while loading your followers.")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.saveButtonTapped)
                    } label: {
                        Text(L10n.Button.save)
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewStore.send(.cancelButtonTapped)
                    } label: {
                        Text(L10n.Button.cancel)
                    }
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.accent)
        .scrollContentBackgroundHidden()
    }
}

// MARK: - Preview

struct InviteUsersToChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        InviteUsersToChallengeView(
            store: .init(
                initialState: .loading,
                reducer: InviteUsersToChallenge()
            )
        )
    }
}
