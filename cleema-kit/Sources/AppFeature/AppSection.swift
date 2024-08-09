//
//  Created by Kumpels and Friends on 12.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUI

extension App.Section: Identifiable {
    public var id: Self { self }
}

extension App.Section {
    var title: String {
        switch self {
        case .dashboard:
            return L10n.home
        case .news:
            return L10n.news
        case .projects:
            return L10n.projects
        case .challenges:
            return L10n.challenges
        case .marketplace:
            return L10n.market
        }
    }

    var image: Image {
        switch self {
        case .dashboard:
            return Image("home-tab-icon", bundle: .module)
        case .news:
            return Image("news-tab-icon", bundle: .module)
        case .projects:
            return Image("projects-tab-icon", bundle: .module)
        case .challenges:
            return Image("challenges-tab-icon", bundle: .module)
        case .marketplace:
            return Image("marketplace-tab-icon", bundle: .module)
        }
    }

    @ViewBuilder
    func content(for store: StoreOf<App>) -> some View {
        switch self {
        case .dashboard:
            DashboardView(store: store.scope(state: \.dashboardState, action: App.Action.dashboard))
        case .news:
            NewsView(store: store.scope(state: \.newsState, action: App.Action.news))
        case .projects:
            ProjectsView(store: store.scope(state: \.projectsState, action: App.Action.projects))
        case .challenges:
            ChallengesView(store: store.scope(state: \.challengesState, action: App.Action.challenges))
        case .marketplace:
            MarketplaceView(store: store.scope(state: \.marketplaceState, action: App.Action.marketplace))
        }
    }
}
