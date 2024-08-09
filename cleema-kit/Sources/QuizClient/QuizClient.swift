//
//  Created by Kumpels and Friends on 21.11.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Dependencies
import Foundation
import Models
import XCTestDynamicOverlay

public struct QuizClient {
    public var loadState: @Sendable (Region.ID?) async throws -> QuizState
    public var saveState: @Sendable (QuizState) async throws -> Void

    public init(
        loadState: @escaping @Sendable (Region.ID?) async throws -> QuizState,
        saveState: @escaping @Sendable (QuizState) async throws -> Void
    ) {
        self.loadState = loadState
        self.saveState = saveState
    }
}

public extension QuizClient {
    static let preview: Self = {
        let quizStore = QuizStore()
        return .init(
            loadState: { _ in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                return await quizStore.state
            },
            saveState: {
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                await quizStore.update($0)
            }
        )
    }()

    static let unimplemented: Self = QuizClient(
        loadState: XCTUnimplemented("loadState"),
        saveState: XCTUnimplemented("saveState")
    )
}

public enum QuizClientKey: TestDependencyKey {
    public static let testValue = QuizClient.unimplemented
    public static let previewValue = QuizClient.preview
}

public extension DependencyValues {
    var quizClient: QuizClient {
        get { self[QuizClientKey.self] }
        set { self[QuizClientKey.self] = newValue }
    }
}

extension Quiz: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.init(
            question: try container.decode(String.self, forKey: .question),
            choices: [
                Quiz.Choice.a: try container.decodeIfPresent(String.self, forKey: .a),
                .b: try container.decodeIfPresent(String.self, forKey: .b),
                .c: try container.decodeIfPresent(String.self, forKey: .c),
                .d: try container.decodeIfPresent(String.self, forKey: .d)
            ].compactMapValues { $0 },
            correctAnswer: try Choice(rawValue: container.decode(String.self, forKey: .correctAnswer))!,
            explanation: try container.decode(String.self, forKey: .explanation)
        )
    }

    enum CodingKeys: String, CodingKey {
        case question
        case a
        case b
        case c
        case d
        case correctAnswer = "answer"
        case explanation
    }
}
