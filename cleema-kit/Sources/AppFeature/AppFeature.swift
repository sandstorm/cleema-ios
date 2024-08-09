//
//  Created by Kumpels and Friends on 31.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Alerts
import BecomePartner
import BecomeSponsor
import ChallengesFeature
import DashboardFeature
import DeepLinking
import Foundation
import InfoFeature
import Logging
import MarketplaceFeature
import NewsFeature
import ProfileFeature
import ProjectsFeature
import QuizFeature
import SurveysFeature
import TrophyClient

public struct App: ReducerProtocol {
    public enum DialogState: Equatable {
        case acceptInvitation(SocialUser)
        case trophy(Trophy)
        case invite
    }

    public enum SheetState: Equatable {
        case inviteActivity(URL)
        case profile(Profile.State)
        case info(InfoDetail.State)
    }

    public enum Destination: Equatable {
        case dialog(DialogState)
        case sheet(SheetState)
        case alert(AlertState<Action>)
    }

    public enum Section: Int, Hashable, CaseIterable {
        case dashboard
        case news
        case projects
        case challenges
        case marketplace
    }

    public enum ShareInvitationState: Equatable {
        case showsDialog
        case showsActivitySheet(URL)
    }

    public struct State: Equatable {
        public var quizState: QuizFeature.State
        public var surveysState: Surveys.State
        public var dashboardGridState: DashboardGrid.State
        public var newsState: AllNews.State
        public var projectsState: Projects.State
        public var challengesState: Challenges.State
        public var marketplaceState: Marketplace.State
        public var selectedSection: Section
        public var challengeSelection: Identified<JoinedChallenge.ID, UserChallenge.State>?
        public var user: User?
        public var destination: Destination?
        public var becomeSponsorState: BecomeSponsor.State?
        public var becomePartnerState: BecomePartner.State?

        public init(
            quizState: QuizFeature.State = .init(),
            surveysState: Surveys.State = .init(),
            dashboardGridState: DashboardGrid.State = .init(),
            newsState: AllNews.State,
            projectsState: Projects.State,
            challengesState: Challenges.State,
            marketplaceState: Marketplace.State,
            selectedSection: Section = .dashboard,
            destination: Destination? = nil,
            becomeSponsorState: BecomeSponsor.State? = nil,
            becomePartnerState: BecomePartner.State? = nil
        ) {
            self.quizState = quizState
            self.surveysState = surveysState
            self.dashboardGridState = dashboardGridState
            self.newsState = newsState
            self.projectsState = projectsState
            self.challengesState = challengesState
            self.marketplaceState = marketplaceState
            self.selectedSection = selectedSection
            self.destination = destination
            self.becomeSponsorState = becomeSponsorState
            self.becomePartnerState = becomePartnerState
        }
    }

    public enum Action: Equatable {
        case task
        case userResult(User?)
        case dashboard(Dashboard.Action)
        case news(AllNews.Action)
        case projects(Projects.Action)
        case challenges(Challenges.Action)
        case marketplace(Marketplace.Action)
        case profile(Profile.Action)
        case info(InfoDetail.Action)
        case followInvitationResponse(TaskResult<SocialGraphItem>)
        case invitationButtonTapped
        case dismissDestination
        case handleAppRoute(AppRoute)
        case handleAppRouteResponse
        case newTrophiesResponse(TaskResult<[Trophy]>)
        case selectSection(App.Section)
    }

    @Dependency(\.userClient) private var userClient
    @Dependency(\.log) private var log
    @Dependency(\.deepLinkingClient) private var deepLinkingClient
    @Dependency(\.trophyClient) private var trophyClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.dashboardState, action: /Action.dashboard) {
            Dashboard()
        }
        Scope(state: \.newsState, action: /Action.news) {
            AllNews()
        }

        Scope(state: \.projectsState, action: /Action.projects) {
            Projects()
        }

        Scope(state: \.challengesState, action: /Action.challenges) {
            Challenges()
        }

        Scope(state: \.marketplaceState, action: /Action.marketplace) {
            Marketplace()
        }

        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await user in userClient.userStream().compactMap({ $0?.user }) {
                        await send(.userResult(user))
                    }
                }
            case let .userResult(user?):
                state.user = user
                return .none
            case .userResult:
                return .none
            case .dashboard(.load):
                return .task {
                    try await userClient.reloadUser()
                    return .newTrophiesResponse(
                        await TaskResult {
                            try await trophyClient.newTrophies()
                        }
                    )
                }
            case let .newTrophiesResponse(.success(newTrophies)):
                guard let trophy = newTrophies.first else { return .none }
                state.destination = .dialog(.trophy(trophy))
                return .none

            case let .newTrophiesResponse(.failure(error)):
                return .fireAndForget { [error] in
                    log.error("Error receiving trophies", userInfo: error.logInfo)
                }

            case .dashboard(.profileButtonTapped), .news(.profileButtonTapped), .projects(.profileButtonTapped),
                 .challenges(.profileButtonTapped), .marketplace(.profileButtonTapped):
                state.destination = .sheet(.profile(.init()))
                return .none

            //case .dashboard(.infoButtonTapped(.partnership)):
            //    state.becomePartnerState = .init()
            //    return .none

            case .dashboard(.infoButtonTapped(.sponsorship)):
                // TODO: Test me
                if state.user?.kind == User.Kind.local {
                    state.destination = .alert(.sponsorAlert)
                } else {
                    state.becomeSponsorState = .init()
                }

                return .none

            case let .dashboard(.infoButtonTapped(infoID)):
                state.infoState = .init(id: infoID)
                return .none

            case let .profile(.userFavorites(.projectDetail(.projectResponse(.success(favedProject))))):
                guard case let .project(projectState) = state.profileState?.userFavoritesState.selection?.value
                else { return .none }
                state.projectsState.projects[id: projectState.project.id]?.project.isFaved = favedProject.isFaved
                return .none

            case let .profile(.profileData(.editProfile(.saveResult(.success(user))))):
                state.surveysState.userAcceptedSurveys = user.acceptsSurveys
                guard user.region.id != state.newsState.searchState.region else { return .none }
                state.newsState.searchState.region = user.region.id
                return .task {
                    .news(.load)
                }
            case .dashboard(.grid(.socialItemTapped)):
                state.destination = .dialog(.invite)
                return .none

            case let .selectSection(section):
                if section == state.selectedSection {
                    return selectRoot(of: section)
                } else {
                    state.selectedSection = section
                    return .none
                }

            case .dashboard, .news, .projects, .challenges, .marketplace, .profile, .info:
                return .none

            case let .handleAppRoute(route):
                return handleDeepLink(route: route, state: &state)

            case let .followInvitationResponse(.success(item)):
                state.destination = .dialog(.acceptInvitation(item.user))
                return .none

            case let .followInvitationResponse(.failure(error)):
                state.destination = .alert(.errorResponse(message: error.localizedDescription))
                return .none

            case .dismissDestination:
                if state.destination == .alert(.sponsorAlert) {
                    state.destination = .sheet(.profile(.init()))
                } else {
                    state.destination = nil
                }
                return .none

            case .invitationButtonTapped:
                guard let code = state.user?.referralCode else { return .none }
                state.destination = .sheet(.inviteActivity(deepLinkingClient.urlForRoute(.invitation(code))))
                return .none

            case .handleAppRouteResponse:
                return .none
            }
        }
        .ifLet(\.profileState, action: /Action.profile) {
            Profile()
        }
        .ifLet(\.infoState, action: /Action.info) {
            InfoDetail()
        }
    }

    private func selectRoot(of section: App.Section) -> EffectTask<Action> {
        switch section {
        case .dashboard:
            return .merge(
                .task { .dashboard(.grid(.setNavigation(selection: nil))) },
                .task { .dashboard(.joinedChallengeList(.setNavigation(selection: nil))) }
            )
        case .news:
            return .task { .news(.setNavigation(selection: nil)) }
        case .projects:
            return .task { .projects(.setNavigation(selection: nil)) }
        case .challenges:
            return .merge(
                .task {
                    .challenges(.joinedChallenges(.setNavigation(selection: nil)))
                },
                .task {
                    .challenges(.partnerChallenges(.setNavigation(nil)))
                }
            )
        case .marketplace:
            return .task {
                .marketplace(.setNavigation(selection: nil))
            }
        }
    }

    private func handleDeepLink(route: AppRoute, state: inout State) -> EffectTask<Action> {
        switch route {
        case let .invitation(referralCode):
            guard let user = state.user else { return .none }

            if user.kind == .local {
                state.destination = .alert(.followInvitationNotPossible)
                return .task {
                    .handleAppRouteResponse
                }
            } else {
                return .concatenate(
                    .task {
                        await .followInvitationResponse(
                            TaskResult {
                                try await userClient.followInvitation(referralCode)
                            }
                        )
                    }
                    .animation(),
                    .task {
                        .handleAppRouteResponse
                    }
                )
            }
        case .becomeSponsor, .becomeSponsorForUserWithID, .emailConfirmationRequest:
            return .none
        }
    }
}

extension App.State {
    var dashboardState: Dashboard.State {
        get {
            .init(
                quizState: quizState,
                surveysState: surveysState,
                gridState: dashboardGridState,
                joinedChallengesState: .init(
                    challenges: Array(challengesState.joinedChallengesState.challenges),
                    selection: challengeSelection
                ),
                becomeSponsorState: becomeSponsorState,
                becomePartnerState: becomePartnerState
            )
        }
        set {
            quizState = newValue.quizState
            surveysState = newValue.surveysState
            dashboardGridState = newValue.gridState
            challengesState.joinedChallengesState.challenges = newValue.joinedChallengesState.challenges
            challengeSelection = newValue.joinedChallengesState.selection
            becomeSponsorState = newValue.becomeSponsorState
            becomePartnerState = newValue.becomePartnerState
        }
    }

    var alertState: AlertState<App.Action>? {
        get {
            guard case let .alert(state) = destination else {
                return nil
            }
            return state
        }
        set {
            destination = newValue.map(App.Destination.alert)
        }
    }

    var profileState: Profile.State? {
        get {
            guard case let .sheet(.profile(state)) = destination else {
                return nil
            }
            return state
        }
        set {
            guard let newValue else {
                destination = nil
                return
            }
            destination = .sheet(.profile(newValue))
        }
    }

    var infoState: InfoDetail.State? {
        get {
            guard case let .sheet(.info(state)) = destination else {
                return nil
            }
            return state
        }
        set {
            guard let newValue else {
                destination = nil
                return
            }
            destination = .sheet(.info(newValue))
        }
    }

    public init(user: User) {
        self.init(
            quizState: .init(region: user.region.id),
            surveysState: .init(userAcceptedSurveys: user.acceptsSurveys),
            dashboardGridState: .init(),
            newsState: .init(searchState: .init(region: user.region.id)),
            projectsState: .init(selectRegionState: .init(
                selectedRegion: user.region
            )),
            challengesState: .init(selectRegionState: .init(
                selectedRegion: user.region
            ), userRegion: user.region),
            marketplaceState: .init(selectRegionState: .init(
                selectedRegion: user.region
            )),
            selectedSection: .dashboard
        )
    }
}

extension AlertState where Action == App.Action {
    static let sponsorAlert: Self = .init(
        title: TextState(L10n.Alert.Sponsor.LocalUser.title),
        message: TextState(L10n.Alert.Sponsor.LocalUser.message),
        buttons: [
            .cancel(
                TextState(L10n.Alert.Sponsor.LocalUser.button)
            )
        ]
    )
}
