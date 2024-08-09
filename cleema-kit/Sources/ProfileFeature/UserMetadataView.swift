//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct UserMetadataView: View {
    let store: StoreOf<ProfileUser>

    @State private var showsPopover = false

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let user = viewStore.user {
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.name)
                        .font(.montserratBold(style: .title, size: 16))
                    VStack(alignment: .leading, spacing: 0) {
                        Text(user.region.name)
                            .font(.montserrat(style: .caption, size: 14))
                        Text(
                            L10n.Account.ActiveSince
                                .label(user.joinDate.formatted(date: .numeric, time: .omitted))
                        )
                        .font(.montserrat(style: .caption, size: 14))
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text(user.kind.title)
                            .font(.montserrat(style: .caption, size: 14))

                        Button {
                            viewStore.send(.accountInfoButtonTapped)
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.defaultText)
                        }
                        .alwaysPopover(
                            isPresented: viewStore
                                .binding(get: { $0.accountInfo != nil }, send: .dismissAccountInfo)
                        ) {
                            if let accountInfo = viewStore.accountInfo {
                                Text(accountInfo)
                                    .font(.montserrat(style: .body, size: 14))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .frame(maxWidth: 300)
                            }
                        }
                    }

                    if user.kind == .local {
                        Divider()
                            .frame(minHeight: 1)
                            .background(Color.defaultText)
                            .padding(.vertical, 8)

                        Button(L10n.Button.ConvertAccount.label) {
                            viewStore.send(.convertAccountButtonTapped, animation: .default)
                        }
                        .buttonStyle(.action(maxWidth: .infinity))
                        .padding(.top, 12)

                        Text(L10n.ConvertAccount.info)
                            .font(.montserrat(style: .caption, size: 12).leading(.tight))
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Divider()
                            .frame(minHeight: 1)
                            .background(Color.defaultText)
                            .padding(.vertical, 8)

                        HStack(alignment: .bottom, spacing: 12) {
                            Button {
                                viewStore.send(.showFollowersTapped)
                            } label: {
                                Text(L10n.Account.Followers.label(user.followerCount))
                                    .multilineTextAlignment(.leading)
                            }

                            Button {
                                viewStore.send(.showFollowingsTapped)
                            } label: {
                                Text(L10n.Account.Following.label(user.followingCount))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.action)
                        .font(.montserrat(style: .body, size: 14))

                        Button(L10n.Button.Invite.label) {
                            viewStore.send(.inviteButtonTapped)
                        }
                        .buttonStyle(.action(maxWidth: .infinity))
                        .padding(.top, 12)
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct UserMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        UserMetadataView(
            store: .init(
                initialState: .init(user: User(
                    name: "Clara cleema",
                    region: .leipzig,
                    joinDate: .now,
                    referralCode: "1234"
                )),
                reducer: ProfileUser()
            )
        )
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.defaultText)
        .background(Color.accent)
//        .cleemaStyle()
    }
}
