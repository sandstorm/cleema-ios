//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import AvatarClient
import Components
import ComposableArchitecture
import Logging
import Models

public struct SelectAvatar: ReducerProtocol {
    public struct State: Equatable {
        public var selectedAvatar: IdentifiedImage?
        public var avatars: IdentifiedArrayOf<IdentifiedImage>
        public init(
            selectedAvatar: IdentifiedImage?,
            avatars: IdentifiedArrayOf<IdentifiedImage> = []
        ) {
            self.selectedAvatar = selectedAvatar
            self.avatars = avatars
        }
    }

    public enum Action: Equatable {
        case task
        case taskResult(TaskResult<[IdentifiedImage]>)
        case selectAvatar(IdentifiedImage)
        case cancelButtonTapped
        case saveButtonTapped
    }

    @Dependency(\.avatarClient.loadAvatars) private var loadAvatars
    @Dependency(\.log) private var log

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            return .task {
                .taskResult(
                    await TaskResult {
                        try await loadAvatars()
                    }
                )
            }
        case let .taskResult(.success(avatars)):
            state.avatars = .init(uniqueElements: avatars)
            return .none
        case let .selectAvatar(avatar):
            state.selectedAvatar = avatar
            return .none
        case let .taskResult(.failure(error)):
            return .fireAndForget {
                log.error("Error loading avatars", userInfo: error.logInfo)
            }
        case .cancelButtonTapped:
            return .none
        case .saveButtonTapped:
            return .none
        }
    }
}
