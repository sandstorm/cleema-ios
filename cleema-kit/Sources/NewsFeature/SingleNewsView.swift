//
//  Created by Kumpels and Friends on 20.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import MarkdownUI
import Models
import NukeUI
import SwiftUI
import SwiftUIBackports

public struct SingleNewsView: View {
    let store: StoreOf<NewsDetail>

    public init(store: StoreOf<NewsDetail>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    CustomLazyImage(url: viewStore.image?.url)
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
                                viewStore.send(.favoriteTapped)
                            } label: {
                                Image(systemName: viewStore.isFaved ? "star.fill" : "star")
                                    .foregroundColor(.action)
                            }
                        }
                        Markdown(viewStore.teaser)
                            .accentColor(.action)

                        Spacer()

                        Divider()

                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Backport.Flow(data: viewStore.tags, spacing: 4) { tag in
                                Button {
                                    viewStore.send(.tagTapped(tag))
                                } label: {
                                    TagView(tag: tag)
                                }
                            }

                            Spacer()

                            Button(L10n.News.MoreButton.label) {
                                viewStore.send(.tapped)
                            }
                            .buttonStyle(MoreButtonStyle())
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                }
                BadgeView(text: viewStore.type.badgeText, color: viewStore.type.badgeColor)
            }
            .padding(.bottom, 20)
            .frame(maxHeight: 800)
            .background(.white)
            .onTapGesture {
                viewStore.send(.tapped)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .cardShadow()
        }
    }
}

extension News.NewsType {
    var badgeText: String {
        switch self {
        case .news:
            return L10n.News.NewsType.news
        case .tip:
            return L10n.News.NewsType.tip
        }
    }

    var badgeColor: Color {
        switch self {
        case .news:
            return .news
        case .tip:
            return .tip
        }
    }
}

struct MoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.montserratBold(style: .footnote, size: 14))
            .foregroundColor(.action)
            .blendMode(configuration.isPressed ? .hardLight : .normal)
    }
}

// MARK: - Preview

struct SingleNewsView_Previews: PreviewProvider {
    static var previews: some View {
        SingleNewsView(
            store: Store(
                initialState: .fake(),
                reducer: NewsDetail()
            )
        )
        .padding()
        .groupBoxStyle(.plain)
        .background(.gray)
    }
}
