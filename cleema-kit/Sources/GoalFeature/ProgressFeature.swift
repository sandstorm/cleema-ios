import Foundation
import ComposableArchitecture

public struct ProgressState: Equatable {
    public var count: UInt
    public var isDecrementButtonEnabled: Bool

    public init(count: UInt = 1, isDecrementButtonEnabled: Bool = false) {
        self.count = count
        self.isDecrementButtonEnabled = isDecrementButtonEnabled
    }
}

public enum ProgressAction: Equatable {
    case incrTapped
    case decrTapped
}

public let progressReducer: Reducer<ProgressState, ProgressAction, Void> = Reducer { state, action, _ in
    switch action {
    case .incrTapped:
        state.count += 1
        state.isDecrementButtonEnabled = true
        return .none
    case .decrTapped:
        guard state.isDecrementButtonEnabled else { return .none }
        state.count -= 1
        state.isDecrementButtonEnabled = state.count != 1
        return .none
    }
}
