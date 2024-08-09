//
//  Created by Kumpels and Friends on 16.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import NukeUI
import SwiftUI

public struct SelectAvatarView: View {
    let store: StoreOf<SelectAvatar>

    let columns = [
        GridItem(.adaptive(minimum: 104, maximum: 104), spacing: 16)
    ]

    public init(store: StoreOf<SelectAvatar>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(viewStore.avatars) { avatar in
                            Button {
                                viewStore.send(.selectAvatar(avatar))
                            } label: {
                                LazyImage(url: avatar.image.url) { state in
                                    if let image = state.image {
                                        image
                                            .resizingMode(.aspectFit)
                                    }
                                }
                            }
                            .buttonStyle(AvatarButtonStyle(isSelected: viewStore.selectedAvatar?.id == avatar.id))
                        }
                    }
                    .padding(.top, 24)
                }
                .background(Color.accent, ignoresSafeAreaEdges: .all)
                .navigationTitle(L10n.Sheet.SelectAvatar.title)
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackgroundHidden()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            viewStore.send(.cancelButtonTapped)
                        } label: {
                            Text(L10n.Form.Action.Cancel.label)
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            viewStore.send(.saveButtonTapped)
                        } label: {
                            Text(L10n.Form.Action.Select.label)
                        }
                    }
                }
            }
            .task {
                viewStore.send(.task)
            }
        }
    }
}

// MARK: - Preview

struct SelectAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        SelectAvatarView(
            store: .init(
                initialState: .init(selectedAvatar: .fake()),
                reducer: SelectAvatar()
            )
        )
        .cleemaStyle()
    }
}

struct AvatarButtonStyle: ButtonStyle {
    var isSelected: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 104, height: 104)
            .clipShape(Circle())
            .brightness(isSelected ? 0 : -0.05)
            .overlay {
                if isSelected || configuration.isPressed {
                    Circle()
                        .stroke(Color.action, lineWidth: 4)
                        .padding(2)
                }
            }
            .circleShadow(isVisible: isSelected)
            .compositingGroup()
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.easeInOut, value: isSelected)
    }
}
