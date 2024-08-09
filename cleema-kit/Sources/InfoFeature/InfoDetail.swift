//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import BecomeSponsor
import ComposableArchitecture
import DeepLinking
import InfoClient
import MarkdownUI
import Models
import Styling
import SwiftUI
import SwiftUINavigation
import UserClient

public struct InfoDetail: ReducerProtocol {
    public enum ID: CaseIterable, Identifiable {
        case sponsorship
        case partnership
        case about
        case imprint
        case privacyPolicy

        public var id: InfoDetail.ID {
            self
        }
    }

    public struct State: Equatable {
        var id: InfoDetail.ID
        var markdown: String?
        var userID: User.ID?

        public init(id: InfoDetail.ID) {
            self.id = id
        }
    }

    public enum Action: Equatable {
        case task
        case load
        case userIDResponse(User.ID)
        case loadResponse(TaskResult<InfoContent>)
    }

    @Dependency(\.infoClient) private var infoClient
    @Dependency(\.userClient) private var userClient

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await userID in userClient.userStream().compactMap({ $0?.user?.id }) {
                        await send(.userIDResponse(userID))
                    }
                }
            case let .userIDResponse(userID):
                state.userID = userID
                return .none
            case .load:
                switch state.id {
                case .about:
                    return .task {
                        await .loadResponse(TaskResult { try await infoClient.loadAbout() })
                    }
                case .privacyPolicy:
                    return .task {
                        await .loadResponse(TaskResult { try await infoClient.loadPrivacy() })
                    }
                case .imprint:
                    return .task {
                        await .loadResponse(TaskResult { try await infoClient.loadImprint() })
                    }
                case .partnership:
                    return .task {
                        await .loadResponse(TaskResult { try await infoClient.loadPartnership() })
                    }
                case .sponsorship:
                    return .none
                }
            case let .loadResponse(.success(content)):
                state.markdown = content.text
                return .none
            case .loadResponse(.failure):
                // TODO: handle error
                return .none
            }
        }
    }
}

// MARK: - View

public struct InfoDetailView: View {
    let store: StoreOf<InfoDetail>

    @Dependency(\.deepLinkingClient.routeForURL) private var routeForURL

    public init(store: StoreOf<InfoDetail>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if let markdown = viewStore.markdown {
                    ScrollView {
                        Markdown(markdown)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accentColor(.action)
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(viewStore.id.title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewStore.send(.load)
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
        .background(Color.accent)
    }
}

public extension InfoDetail.ID {
    var title: String {
        switch self {
        case .about:
            return L10n.Button.about
        case .privacyPolicy:
            return L10n.Button.privacyPolicy
        case .imprint:
            return L10n.Button.imprint
        case .partnership:
            return L10n.Button.partnership
        case .sponsorship:
            return L10n.Button.sponsorship
        }
    }
}

// MARK: - Preview

struct InfoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InfoDetailView(
                store: .init(
                    initialState: .init(
                        id: .partnership
                    ),
                    reducer: InfoDetail()
                )
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.defaultText)
        .background(Color.accent)
        .cleemaStyle()
    }
}
