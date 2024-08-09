//
//  Created by Kumpels and Friends on 06.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import DeepLinking
import Foundation
import Logging
import Models
import ProjectDetailFeature
import SwiftUI
import UserChallengeFeature

public struct DashboardGrid: ReducerProtocol {
    public enum Selection: Equatable {
        case project(ProjectDetail.State)
        case challenge(UserChallenge.State)
    }

    public enum Dimension: Int, Comparable, Equatable {
        case small
        case medium
        case large

        public static func < (lhs: Dimension, rhs: Dimension) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public enum ItemType: Equatable, Identifiable {
        case social(SocialItem)
        case project(Project)
        case challenge(JoinedChallenge)

        public var id: UUID {
            switch self {
            case let .social(item): return item.id.rawValue
            case let .project(item): return item.id.rawValue
            case let .challenge(item): return item.id.rawValue
            }
        }
    }

    public struct Item: Identifiable, Equatable {
        public var id: ItemType.ID {
            content.id
        }

        public var content: ItemType
        public var isWaveMirrored = false

        public init(
            content: ItemType,
            isWaveMirrored: Bool = false
        ) {
            self.content = content
            self.isWaveMirrored = isWaveMirrored
        }

        var dimension: Dimension {
            switch content {
            case .social: return .small
            case .project: return .large
            case .challenge: return .medium
            }
        }
    }

    public struct State: Equatable {
        public var user: User?
        public var firstRow: IdentifiedArrayOf<Item> = []
        public var secondRow: IdentifiedArrayOf<Item> = []
        public var isLoading: Bool = true
        public var selection: Identified<Item.ID, Selection>? {
            didSet {
                guard let selection = selection else { return }
                switch selection.value {
                case let .project(project):
                    guard var item = firstRow[id: selection.id] else { return }
                    item.content = .project(project.project)
                    firstRow[id: selection.id] = item
                case .challenge:
                    break
                }
            }
        }

        public init(
            firstRow: IdentifiedArrayOf<Item> = [],
            secondRow: IdentifiedArrayOf<Item> = [],
            selection: Identified<Item.ID, Selection>? = nil,
            isLoading: Bool = false
        ) {
            self.firstRow = firstRow
            self.secondRow = secondRow
            self.selection = selection
            self.isLoading = isLoading
        }
    }

    public struct ContentResponse: Equatable {
        public var projects: [Project]
        public var socialItems: [SocialItem]

        public init(projects: [Project], socialItems: [SocialItem]) {
            self.projects = projects
            self.socialItems = socialItems
        }
    }

    public enum Action: Equatable {
        case task
        case userResult(User?)
        case contentResponse(TaskResult<ContentResponse>)
        case setNavigation(selection: Item.ID?)
        case project(ProjectDetail.Action)
        case challenge(UserChallenge.Action)
        case socialItemTapped
    }

    @Dependency(\.userClient) private var userClient
    @Dependency(\.projectsClient.projects) private var projects
    @Dependency(\.uuid) private var uuid
    @Dependency(\.log) private var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .run { send in
                    for await user in userClient.userStream().compactMap({ $0?.user }) {
                        await send(.userResult(user))
                    }
                }
            case let .userResult(user?):
                state.user = user
                return .task { [followerCount = user.followerCount] in
                    await .contentResponse(
                        TaskResult {
                            try await .init(
                                projects: projects(nil).filter { $0.isFaved || $0.isJoined },
                                socialItems: [SocialItem(
                                    id: .init(uuid()),
                                    title: L10n.Invite.title,
                                    text: L10n.Invite.followerCount(followerCount),
                                    badgeNumber: followerCount
                                )]
                            )
                        }
                    )
                }
                .animation(.default)
            case .userResult:
                return .none
            case let .contentResponse(.success(response)):
                state.firstRow = {
                    var content: [Item] = []
                    if let social = response.socialItems.first {
                        content.append(Item(social: social, isWaveMirrored: false))
                    }
                    content.append(contentsOf: response.projects.map { Item(project: $0, isWaveMirrored: true) })
                    return .init(IdentifiedArray(uniqueElements: content))
                }()

                state.validateMirrorState()
                state.isLoading = false
                return .none
            case let .contentResponse(.failure(error)):
                return .fireAndForget {
                    log.error("Error loading content", userInfo: error.logInfo)
                }
            case let .setNavigation(selection: itemID?):
                guard
                    let item = state.item(with: itemID)
                else { return .none }
                switch item.content {
                case let .project(project):
                    state.selection = Identified(.project(.init(project: project)), id: itemID)
                case let .challenge(challenge):
                    state.selection = Identified(.challenge(.init(userChallenge: challenge)), id: itemID)
                default: break
                }
                return .none
            case .setNavigation(selection: nil):
                state.selection = nil
                return .none
            case .project:
                return .none
            case .challenge:
                return .none
            case .socialItemTapped:
                return .none
            }
        }
        .ifLet(\.selection, action: /Action.project) {
            Scope(state: \Identified.value, action: .self) {
                Scope(
                    state: /Selection.project,
                    action: .self
                ) {
                    ProjectDetail()
                }
            }
        }
        .ifLet(\.selection, action: /Action.challenge) {
            Scope(state: \Identified.value, action: .self) {
                Scope(
                    state: /Selection.challenge,
                    action: .self
                ) {
                    UserChallenge()
                }
            }
        }
    }
}

extension DashboardGrid.Item {
    var title: String {
        switch content {
        case let .social(socialItem):
            return socialItem.title
        case let .project(project):
            return project.title
        case let .challenge(userChallenge):
            return userChallenge.challenge.title
        }
    }

    var text: String {
        switch content {
        case let .social(socialItem):
            return socialItem.text
        case let .project(project):
            return project.partner.title
        case let .challenge(userChallenge):
            return userChallenge.challenge.description
        }
    }

    var badge: String {
        switch content {
        case let .social(socialItem):
            return socialItem.badgeNumber.formatted()
        case let .project(project):
            return project.isFaved ? "★" : ""
        case .challenge:
            return ""
        }
    }

    var image: RemoteImage? {
        switch content {
        case .social, .challenge:
            return nil
        case let .project(project):
            return project.teaserImage
        }
    }

    init(project: Project, isWaveMirrored: Bool) {
        self.init(content: .project(project), isWaveMirrored: isWaveMirrored)
    }

    init(social: SocialItem, isWaveMirrored: Bool) {
        self.init(content: .social(social), isWaveMirrored: isWaveMirrored)
    }
}

extension DashboardGrid.Dimension {
    var waveImage: Image? {
        switch self {
        case .small:
            return Image("waveSmall", bundle: .module)
        case .medium:
            return nil
        case .large:
            return Image("waveLarge", bundle: .module)
        }
    }
}

extension DashboardGrid.State {
    func item(with id: DashboardGrid.Item.ID) -> DashboardGrid.Item? {
        firstRow[id: id] ?? secondRow[id: id]
    }

    mutating func validateMirrorState() {
        for (idx, value) in firstRow.enumerated() {
            firstRow[id: value.id]!.isWaveMirrored = !idx.isMultiple(of: 2)
        }
        for (idx, value) in secondRow.enumerated() {
            secondRow[id: value.id]!.isWaveMirrored = !idx.isMultiple(of: 2)
        }
    }
}
