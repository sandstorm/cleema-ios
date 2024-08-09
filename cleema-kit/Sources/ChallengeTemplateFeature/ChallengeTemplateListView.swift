//
//  Created by Kumpels and Friends on 12.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Styling
import SwiftUI

public struct ChallengeTemplateListView: View {
    let store: StoreOf<ChallengeTemplates>

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    public init(store: StoreOf<ChallengeTemplates>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 18) {
                    Text(L10n.title)
                        .font(.montserrat(style: .title, size: 24))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(viewStore.challenges) { challenge in
                            NavigationLink(
                                destination: IfLetStore(
                                    store.scope(
                                        state: \.editState?.value,
                                        action: ChallengeTemplates.Action.edit
                                    )
                                ) { editStore in
                                    EditChallengeView(store: editStore)
                                    #if os(iOS)
                                        .navigationBarBackButtonHidden(true)
                                    #endif
                                },
                                tag: challenge.id,
                                selection: viewStore.binding(
                                    get: \.editState?.id,
                                    send: ChallengeTemplates.Action.challengeTapped(id:)
                                )
                            ) {
                                ChallengeView(challenge: challenge)
                                    .cardShadow()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                viewStore.send(.load)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.accent)
    }
}

// MARK: Preview

import Fakes

struct ChallengeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChallengeTemplateListView(
                store: .init(
                    initialState: .init(
                        challenges: .init(
                            uniqueElements: (1 ... 5).map { _ in Challenge.fake() }
                        ),
                        userRegion: .pirna
                    ),
                    reducer: ChallengeTemplates()
                )
            )
            .foregroundColor(.defaultText)
        }
    }
}
