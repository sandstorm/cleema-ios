//
//  Created by Kumpels and Friends on 14.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import Styling
import SwiftUI
import SwiftUIBackports
import SwiftUINavigation

public struct TrophiesFeatureView: View {
    let store: StoreOf<Trophies>

    public init(store: StoreOf<Trophies>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if viewStore.isLoading {
                    ProgressView(L10n.loading)
                        .frame(maxWidth: .infinity)
                } else {
                    if viewStore.trophies.isEmpty {
                        Text(L10n.Trophies.Empty.label)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)
                            .foregroundColor(.recessedText)
                    } else {
                        LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 16)], spacing: 24) {
                            ForEach(viewStore.trophies) { trophy in
                                Button {
                                    viewStore.send(.setNavigation(selection: trophy.id))
                                } label: {
                                    TrophyView(trophy: trophy)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .sheet(
                            unwrapping: viewStore.binding(
                                get: \.selection,
                                send: Trophies.Action.dismissSheet
                            )
                        ) { $trophyID in
                            NavigationView {
                                TrophyDetailView(trophy: trophyID.value)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing) {
                                            Button(L10n.Trophy.Detail.Action.Done.label) {
                                                viewStore.send(.dismissSheet)
                                            }
                                        }
                                    }
                                    .backport.presentationDragIndicator(.visible)
                            }
                            .backport.presentationDetents([.large])
                        }
                    }
                }
            }
            .frame(minHeight: 200)
            .onAppear {
                viewStore.send(.load)
            }
        }
    }
}

struct TrophiesFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                TrophiesFeatureView(
                    store: .init(
                        initialState: .init(),
                        reducer: Trophies()
                    )
                )
            }
        }
    }
}
