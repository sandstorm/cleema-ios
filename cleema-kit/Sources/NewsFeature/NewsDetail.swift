//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import MarkdownUI
import NewsClient
import NukeUI
import Styling
import SwiftUI
import SwiftUIBackports

public struct NewsDetail: ReducerProtocol {
    public init() {}

    public typealias State = News

    public enum Action: Equatable {
        case favoriteTapped
        case singleNewsResponse(TaskResult<News>)
        case tagTapped(Tag)
        case tapped
        case scrollPercentage(CGFloat)
    }

    @Dependency(\.newsClient.fav) private var fav
    @Dependency(\.newsClient.markAsRead) private var markAsRead
    @Dependency(\.log) private var log
    @Dependency(\.mainQueue) private var mainQueue

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        enum ScrollID {}

        switch action {
        case .favoriteTapped:
            return .task { [news = state] in
                await .singleNewsResponse(
                    TaskResult {
                        let value = try await fav(news.id, !news.isFaved)
                        return value
                    }
                )
            }
        case let .singleNewsResponse(.success(news)):
            state = news
            return .none
        case let .singleNewsResponse(.failure(error)):
            return .fireAndForget {
                log.error("Error loading news", userInfo: error.logInfo)
            }
        case .tagTapped, .tapped:
            return .none
        case let .scrollPercentage(percentage):
            return .fireAndForget { [id = state.id] in
                guard percentage > 0.9 else { return }
                try await markAsRead(id)
            }.debounce(id: ScrollID.self, for: .seconds(1), scheduler: mainQueue.eraseToAnyScheduler())
        }
    }
}

public struct NewsDetailView: View {
    let store: StoreOf<NewsDetail>

    @Environment(\.styleGuide) var styleGuide
    var isPresentedInSheet: Bool

    @State private var scrollViewHeight: CGFloat = 1
    @State private var contentHeight: CGFloat = 1

    public init(store: StoreOf<NewsDetail>, isPresentedInSheet: Bool = false) {
        self.store = store
        self.isPresentedInSheet = isPresentedInSheet
    }

    public var body: some View {
        enum ContentID {}
        enum ScrollViewID {}

        return WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                GeometryReader { geometry in
                    let offsetY = -geometry.frame(in: .named("scrollView")).origin.y
                    Color.clear.preference(
                        key: ScrollPercentagePreferenceKey.self,
                        value: (offsetY + scrollViewHeight) / contentHeight
                    )
                }
                .frame(width: 0, height: 0)

                VStack(spacing: 16) {
                    LazyImage(url: viewStore.image?.url, resizingMode: .aspectFill)
                        .frame(height: 208)

                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 8) {
                                if viewStore.type == .news {
                                    Text(viewStore.date.formatted(date: .numeric, time: .omitted))
                                        .font(.montserrat(style: .footnote, size: 14))
                                }

                                Text(viewStore.title)
                                    .font(.montserratBold(style: .headline, size: 16))
                            }

                            Spacer()

                            Button {
                                viewStore.send(.favoriteTapped, animation: .default)
                            } label: {
                                Image(systemName: viewStore.isFaved ? "star.fill" : "star")
                                    .foregroundColor(.action)
                            }
                        }

                        Markdown(viewStore.description)
                            .accentColor(.action)

                        Spacer()

                        Divider()

                        Backport.Flow(data: viewStore.tags, spacing: 4) { tag in
                            TagView(tag: tag)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, styleGuide.screenEdgePadding)
                }
                .padding(.bottom, 20)
                .frame(maxHeight: .infinity)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .cardShadow()
                .padding(.horizontal, styleGuide.screenEdgePadding)
                .padding(.vertical)
                .reportSize(ContentID.self) {
                    contentHeight = $0.height
                }
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollPercentagePreferenceKey.self) {
                viewStore.send(.scrollPercentage($0))
            }
            .reportSize(ScrollViewID.self) {
                scrollViewHeight = $0.height
            }
        }
        .background {
            if isPresentedInSheet {
                Color.accent.ignoresSafeArea()
            } else {
                ScreenBackgroundView()
            }
        }
    }
}

private struct ScrollPercentagePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
