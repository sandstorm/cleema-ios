//
//  Created by Kumpels and Friends on 09.10.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct Debug: ReducerProtocol {
    public typealias State = Date

    public enum Action: Equatable {
        case setDebugDate(Date)
    }

    public init() {}

    public func reduce(into state: inout Date, action: Action) -> EffectTask<Action> {
        switch action {
        case let .setDebugDate(date):
            state = date
            Date.debugDate = date
            return .none
        }
    }
}

public struct DebugView: View {
    let store: StoreOf<Debug>

    public init(store: StoreOf<Debug>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            DatePicker("Set current date", selection: viewStore.binding(send: Debug.Action.setDebugDate))
                .padding()
                .datePickerStyle(.graphical)
        }
    }
}

public extension Date {
    internal(set) static var debugDate: Self = .now
}

public extension DateGenerator {
    static func debug() -> Self {
        .init {
            Date.debugDate
        }
    }
}
