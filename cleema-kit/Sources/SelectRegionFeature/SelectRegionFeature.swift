//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Logging
import Models
import RegionsClient
import Styling
import SwiftUI

public struct SelectRegion: ReducerProtocol {
    public struct State: Equatable {
        public var regions: [Region]
        @BindingState public var selectedRegion: Region?
        public var isLoading = false

        public init(
            regions: [Region] = [],
            selectedRegion: Region? = nil,
            isLoading: Bool = false
        ) {
            self.regions = regions
            self.selectedRegion = selectedRegion
            self.isLoading = isLoading
        }
    }

    public enum Action: Equatable, BindableAction {
        case task
        case regionsResult(TaskResult<[Region]>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.regionsClient.regions) var regions
    @Dependency(\.log) var log

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .task {
                    await .regionsResult(.init {
                        try await regions(nil)
                    })
                }
            case let .regionsResult(.success(regions)):
                state.regions = regions
                state.isLoading = false
                return .none
            case let .regionsResult(.failure(error)):
                // TODO: Handle error
                state.isLoading = false
                return .fireAndForget {
                    log.error("Error fetching region results", userInfo: error.logInfo)
                }
            case .binding:
                return .none
            }
        }
    }
}

// MARK: - View

public struct SelectRegionView: View {
    let store: StoreOf<SelectRegion>
    var showsEmptySelection: Bool = false
    var valuePrefix: String?
    var noSelectionPlaceholder: String
    var horizontalPadding: CGFloat = 12

    public init(
        store: StoreOf<SelectRegion>,
        noSelectionPlaceholder: String = L10n.Picker.SelectRegion.Placeholder.label,
        valuePrefix: String?,
        showsEmptySelection: Bool = false,
        horizontalPadding: CGFloat = 12
    ) {
        self.store = store
        self.noSelectionPlaceholder = noSelectionPlaceholder
        self.showsEmptySelection = showsEmptySelection
        self.valuePrefix = valuePrefix
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Menu {
                    if showsEmptySelection {
                        Button(L10n.Picker.SelectRegion.Empty.label) {
                            viewStore.send(.binding(.set(\.$selectedRegion, nil)), animation: .default)
                        }
                        Divider()
                    }
                    ForEach(viewStore.regions) { region in
                        Button {
                            viewStore.send(.binding(.set(\.$selectedRegion, region)), animation: .default)
                        } label: {
                            Label(
                                labelText(with: region.name),
                                systemImage: region == viewStore.selectedRegion ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    HStack {
                        Text(selectionText(prefix: valuePrefix, selection: viewStore.selectedRegion?.name))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.action)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 8)
                }
                .imageScale(.small)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .task {
                viewStore.send(.task)
            }
        }
    }

    func labelText(with content: String) -> String {
        if let valuePrefix {
            return valuePrefix + " " + content
        } else {
            return content
        }
    }

    func selectionText(prefix: String?, selection: String?) -> String {
        let text = [prefix, selection].compactMap { $0 }.joined(separator: " ")
        guard !text.isEmpty else { return noSelectionPlaceholder }
        return text
    }
}

// MARK: - Preview

struct SelectLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectRegionView(
                store: .init(
                    initialState: .init(),
                    reducer: SelectRegion()
                ),
                valuePrefix: "Choose your region"
            )
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .background {
                ScreenBackgroundView()
            }
        }
        .groupBoxStyle(.plain)
    }
}
