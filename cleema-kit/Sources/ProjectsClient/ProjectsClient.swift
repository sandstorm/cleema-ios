//
//  Created by Kumpels and Friends on 20.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Dependencies
import Foundation
import Models
import Overture

public struct ProjectsClient {
    public var projects: @Sendable (Region.ID?) async throws -> [Project]
    public var join: @Sendable (Project.ID) async throws -> Project
    public var leave: @Sendable (Project.ID) async throws -> Project
    public var support: @Sendable (Project.ID, Int) async throws -> Void
    public var fav: @Sendable (Project.ID, Bool) async throws -> Project
    public var favedProjectsStream: @Sendable () -> AsyncThrowingStream<[Project], Error>

    public init(
        projects: @escaping @Sendable (Region.ID?) async throws -> [Project],
        join: @escaping @Sendable (Project.ID) async throws -> Project,
        leave: @escaping @Sendable (Project.ID) async throws -> Project,
        support: @escaping @Sendable (Project.ID, Int) async throws -> Void,
        fav: @escaping @Sendable (Project.ID, Bool) async throws -> Project,
        favedProjectsStream: @escaping @Sendable () -> AsyncThrowingStream<[Project], Error>
    ) {
        self.projects = projects
        self.join = join
        self.leave = leave
        self.support = support
        self.fav = fav
        self.favedProjectsStream = favedProjectsStream
    }
}

public extension ProjectsClient {
    static let preview: Self = {
        struct FakeError: Error {}
        let fakeProjects: ActorIsolated<[Project]> = .init(.demo.map { with($0, set(\.isFaved, .random())) })
        return .init(
            projects: { regionID in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                return await fakeProjects.value.filter { $0.region.id == regionID }
            },
            join: { joinedID in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                guard var p = await fakeProjects.value.first(where: { $0.id == joinedID }) else { throw FakeError() }
                switch p.goal {
                case let .involvement(currentParticipants, maxParticipant, joined):
                    p.goal = .involvement(
                        currentParticipants: joined ? currentParticipants : currentParticipants + 1,
                        maxParticipants: maxParticipant,
                        joined: true
                    )
                case let .funding(currentAmount: currentAmount, totalAmount: totalAmount):
                    break
                case .information:
                    break
                }
                return p
            },
            leave: { leftID in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                guard var p = await fakeProjects.value.first(where: { $0.id == leftID }) else { throw FakeError() }
                switch p.goal {
                case let .involvement(currentParticipants, maxParticipant, joined):
                    p.goal = .involvement(
                        currentParticipants: joined ? currentParticipants - 1 : currentParticipants,
                        maxParticipants: maxParticipant,
                        joined: false
                    )
                case let .funding(currentAmount: currentAmount, totalAmount: totalAmount):
                    break
                case .information:
                    break
                }
                return p
            }, support: { id, amount in
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                try await fakeProjects.withValue { fakeProjects in
                    guard var index = fakeProjects.firstIndex(where: { $0.id == id }) else { throw FakeError() }
                    switch fakeProjects[index].goal {
                    case .involvement:
                        break
                    case let .funding(currentAmount: currentAmount, totalAmount: totalAmount):
                        fakeProjects[index]
                            .goal = .funding(currentAmount: currentAmount + amount, totalAmount: totalAmount)
                    case .information:
                        break
                    }
                }
            },
            fav: { id, isFaved in
                let result = try await fakeProjects.withValue { fakeProjects in
                    guard var index = fakeProjects.firstIndex(where: { $0.id == id }) else { throw FakeError() }
                    fakeProjects[index].isFaved = isFaved
                    return fakeProjects[index]
                }
                return result
            },
            favedProjectsStream: { AsyncThrowingStream { cont in
                Task {
                    let values = await fakeProjects.value.filter { $0.isFaved }
                    cont.yield(values)
                }
            }
            }
        )
    }()
}

import XCTestDynamicOverlay
public extension ProjectsClient {
    static let unimplemented: Self = ProjectsClient(
        projects: XCTestDynamicOverlay.unimplemented("projects", placeholder: []),
        join: XCTestDynamicOverlay.unimplemented("join"),
        leave: XCTestDynamicOverlay.unimplemented("leave"),
        support: XCTestDynamicOverlay.unimplemented("support"),
        fav: XCTestDynamicOverlay.unimplemented("fav"),
        favedProjectsStream: XCTestDynamicOverlay.unimplemented(
            "favedProjectsStream",
            placeholder: AsyncThrowingStream { nil }
        )
    )
}

public enum ProjectsClientKey: TestDependencyKey {
    public static let testValue = ProjectsClient.unimplemented
    public static let previewValue = ProjectsClient.preview
}

public extension DependencyValues {
    var projectsClient: ProjectsClient {
        get { self[ProjectsClientKey.self] }
        set { self[ProjectsClientKey.self] = newValue }
    }
}
