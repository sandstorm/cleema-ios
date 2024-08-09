//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Models
import NewsClient

public struct SingleNews: ReducerProtocol {
    public typealias State = News

    public enum Action: Equatable {
        case tapped
        case tagTapped(Tag)
        case favoriteTapped
    }

    @Dependency(\.newsClient.fav) var fav

    public init() {}

    public func reduce(into state: inout News, action: Action) -> EffectTask<Action> {
        switch action {
        case .favoriteTapped:
            state.isFaved.toggle()
            return .fireAndForget { [news = state] in
                try await fav(news.id, news.isFaved)
            }
        case .tagTapped:
            return .none
        case .tapped:
            return .none
        }
    }
}
