// swift-tools-version: 5.7

import Foundation
import PackageDescription

let package = Package(
    name: "cleema-kit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: libraries(
        .selectAvatarFeature, .debuggingOverrides, .challengeTemplateFeature, .models, .fakes,
        .editChallengeFeature, .components, .styling, .marketplaceFeature, .newsFeature, .projectDetailFeature,
        .projectsFeature, .dashboardFeature, .appFeature, .userChallengeFeature, .profileFeature,
        .offerRedemptionFeature, .quizFeature, .apiClient, .trophiesFeature, .createUserFeature, .userFavoritesFeature,
        .projectFundingFeature, .partnerChallengesFeature, .logging, .newUserFeature, .registerUserFeature,
        .loginFeature, .authenticateUserFeature, .challengesClient, .infoClient, .infoFeature,
        .inviteUsersToChallengeFeature, .deepLinking, .mainFeature, .userProgressesFeature, .surveysClient,
        .surveysFeature, .profileEditFeature, .avatarClient, .userListFeature, .becomeSponsor, .becomePartner
    ) +
        [
            .plugin(name: "SwiftGenPlugin", targets: ["SwiftGenPlugin"]),
            .library(name: "SelectRegionFeature", targets: ["SelectRegionFeature", "RegionsClient"]),
            .library(name: "RegionsClientLive", targets: ["RegionsClientLive"]),
            .library(name: "NewsClientLive", targets: ["NewsClientLive"]),
            .library(name: "QuizClientLive", targets: ["QuizClientLive"]),
            .library(name: "UserClientLive", targets: ["UserClientLive"]),
            .library(name: "ChallengesClientLive", targets: ["ChallengesClientLive"]),
            .library(name: "MarketplaceClientLive", targets: ["MarketplaceClientLive"]),
            .library(name: "ProjectsClientLive", targets: ["ProjectsClientLive"]),
            .library(name: "InfoClientLive", targets: ["InfoClientLive"]),
            .library(name: "DeepLinkingClientLive", targets: ["DeepLinkingClientLive"]),
            .library(name: "TrophyClientLive", targets: ["TrophyClientLive"]),
            .library(name: "SurveysClientLive", targets: ["SurveysClientLive"]),
            .library(name: "AvatarClientLive", targets: ["AvatarClientLive"]),
            .library(name: "BecomeSponsorClientLive", targets: ["BecomeSponsorClientLive"])
        ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-overture", from: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.7.1"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.8.4"),
        .package(url: "https://github.com/shaps80/SwiftUIBackports.git", from: "1.9.0"),
        .package(url: "https://github.com/kean/Nuke", from: "11.5.3"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing.git", exact: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.9.1"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/gonzalezreal/MarkdownUI", from: "1.1.1"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", from: "1.0.1")

    ],
    targets: [
        .plugin(
            name: "SwiftGenPlugin",
            capability: .buildTool()
        ),
        .debuggingOverrides,
        .models,
        .test(.models, [.overture]),
        .fakes,
        .editChallengeFeature,
        .test(.editChallengeFeature),
        .challengeTemplateFeature,
        .test(.challengeTemplateFeature, [.overture]),
        .userChallengeFeature,
        .test(.userChallengeFeature, [.overture]),
        .challengesFeature,
        .test(.challengesFeature, [.overture]),
        .components,
        .test(.components),
        .styling,
        .marketplaceFeature,
        .test(.marketplaceFeature),
        .newsFeature,
        .test(.newsFeature),
        .projectDetailFeature,
        .test(.projectDetailFeature),
        .projectsFeature,
        .test(.projectsFeature),
        .dashboardFeature,
        .test(.dashboardFeature, [.overture]),
        .appFeature,
        .test(.appFeature),
        .profileFeature,
        .test(.profileFeature),
        .profileEditFeature,
        .test(.profileEditFeature),
        .selectAvatarFeature,
        .test(.selectAvatarFeature),
        .userListFeature,
        .test(.userListFeature),
        .offerRedemptionFeature,
        .test(.offerRedemptionFeature, [.overture]),
        .marketplaceClient,
        .target(
            name: "MarketplaceClientLive",
            dependencies: [
                "APIClient",
                "MarketplaceClient"
            ]
        ),
        .quizFeature,
        .test(.quizFeature, [.algorithms]),
        .trophiesFeature,
        .test(.trophiesFeature),
        .createUserFeature,
        .projectsClient,
        .userFavoritesFeature,
        .test(.userFavoritesFeature, [.overture, .algorithms]),
        .projectFundingFeature,
        .test(.projectFundingFeature),
        .userClient,
        .partnerChallengesFeature,
        .test(.partnerChallengesFeature),
        .challengesClient,
        .quizClient,
        .infoClient,
        .target(
            name: "InfoClientLive",
            dependencies: [
                "APIClient",
                "InfoClient"
            ]
        ),
        .joinedChallengesFeature,
        .dashboardGridFeature,
        .regionsClient,
        .target(
            name: "RegionsClientLive",
            dependencies: [
                "RegionsClient",
                "Models",
                "APIClient",
                .tca
            ]
        ),
        .target(
            name: "NewsClientLive",
            dependencies: [
                "NewsClient",
                "Models",
                "APIClient",
                "Logging",
                .dependencies,
                .asyncAlgorithms
            ]
        ),
        .target(
            name: "QuizClientLive",
            dependencies: [
                "QuizClient",
                "Models",
                "APIClient",
                .dependencies
            ]
        ),
        .selectRegionFeature,
        .test(.selectRegionFeature),
        .apiClient,
        .test(.apiClient),
        .newsClient,
        .logging,
        .registerUserFeature,
        .newUserFeature,
        .test(.newUserFeature),
        .loginFeature,
        .test(.loginFeature),
        .authenticateUserFeature,
        .test(.authenticateUserFeature),
        .boundaries,
        .target(
            name: "UserClientLive",
            dependencies: [
                "Boundaries",
                "APIClient",
                "UserClient",
                "Models",
                .dependencies,
                .keychainAccess,
                .asyncAlgorithms
            ]
        ),
        .target(
            name: "ChallengesClientLive",
            dependencies: [
                "Boundaries",
                "APIClient",
                "ChallengesClient",
                "Models",
                .dependencies,
                .asyncAlgorithms
            ],
            resources: [.process("Resources")],
            plugins: ["SwiftGenPlugin"]
        ),
        .target(
            name: "ProjectsClientLive",
            dependencies: [
                "APIClient",
                "ProjectsClient",
                "Logging",
                "Models",
                .asyncAlgorithms
            ]
        ),
        .infoFeature,
        .inviteUsersToChallengeFeature,
        .test(.inviteUsersToChallengeFeature),
        .deepLinking,
        .test(.deepLinking),
        .target(
            name: "DeepLinkingClientLive",
            dependencies: [
                "DeepLinking"
            ]
        ),
        .mainFeature,
        .test(.mainFeature),
        .alerts,
        .trophyClient,
        .target(
            name: "TrophyClientLive",
            dependencies: [
                "TrophyClient",
                "APIClient",
                .dependencies
            ]
        ),
        .userProgressesFeature,
        .surveysFeature,
        .test(.surveysFeature),
        .surveysClient,
        .target(
            name: "SurveysClientLive",
            dependencies: [
                "SurveysClient",
                "APIClient",
                .dependencies
            ]
        ),
        .avatarClient,
        .target(
            name: "AvatarClientLive",
            dependencies: [
                "APIClient",
                "AvatarClient",
                .dependencies
            ]
        ),
        .becomeSponsor,
        .becomeSponsorClient,
        .target(
            name: "BecomeSponsorClientLive",
            dependencies: [
                "APIClient",
                "BecomeSponsorClient",
                .dependencies
            ]
        ),
        .becomePartner
    ]
)

extension Target {
    static let fakes: Target = .target("Fakes", [])
    static let models: Target = .target("Models", [.tagged] + modules(.fakes))
    static let styling: Target = .target(
        name: "Styling",
        dependencies: [.backports],
        resources: [.process("Fonts"), .process("Resources")],
        plugins: ["SwiftGenPlugin"]
    )
    static let components: Target = .target(
        "Components",
        [.backports, .dependencies, .xctDynOverlay, .nukeUI] + modules(.models, .styling)
    )
    static let marketplaceClient: Target = .target("MarketplaceClient", [.tca] + modules(.models))
    static let logging: Target = .target("Logging", [.dependencies, .xctDynOverlay])
    static let boundaries: Target = .target("Boundaries")
    static let quizClient: Target = .target("QuizClient", [.dependencies] + modules(.models))
    static let quizFeature: Target = .target(
        "QuizFeature",
        [.markdown, .nukeUI, .tca, .overture] + modules(.models, .styling, .quizClient, .logging)
    )
    static let surveysClient: Target = .target("SurveysClient", [.dependencies] + modules(.models))
    static let avatarClient: Target = .target("AvatarClient", [.dependencies] + modules(.models))
    static let challengesClient: Target = .target("ChallengesClient", [.dependencies] + modules(.models))
    static let infoClient: Target = .target("InfoClient", [.dependencies] + modules(.models))
    static let trophyClient: Target = .target("TrophyClient", [.dependencies] + modules(.models))
    static let newsClient: Target = .target("NewsClient", [.dependencies] + modules(.models))
    static let becomeSponsorClient: Target = .target("BecomeSponsorClient", [.dependencies] + modules(.models))
    static let regionsClient: Target = .target("RegionsClient", [.dependencies] + modules(.models))
    static let userClient: Target = .target(
        "UserClient",
        [.xctDynOverlay, .dependencies] + modules(.models, .boundaries)
    )
    static let deepLinking: Target = .target(
        "DeepLinking",
        [.routing, .dependencies, .tca] + modules(.models, .logging, .userClient)
    )
    static let newsFeature: Target = .target(
        "NewsFeature",
        [.markdown, .nukeUI, .tca, .navigation] + modules(.components, .models, styling, .newsClient, .logging)
    )

    static let selectAvatarFeature: Target = .target(
        "SelectAvatarFeature",
        [.tca, .navigation, .nukeUI] + modules(.models, .components, .styling, .avatarClient, .logging)
    )

    static let selectRegionFeature: Target = .target(
        "SelectRegionFeature", [.tca] + modules(.models, .styling, .regionsClient, .logging)
    )
    static let userListFeature: Target = .target(
        "UserListFeature",
        [.tca, .navigation, .nukeUI] + modules(.models, .components, .styling, .userClient, .avatarClient, .logging)
    )
    static let projectsClient: Target = .target(
        "ProjectsClient",
        [.overture, .xctDynOverlay, .dependencies] + modules(.models, .debuggingOverrides)
    )
    static let alerts: Target = .target("Alerts", [.navigation])
    static let becomeSponsor: Target = .target(
        "BecomeSponsor",
        [.tca, .confetti, .markdown] + modules(.becomeSponsorClient, .models, .components)
    )

    static let projectFundingFeature: Target = .target(
        "ProjectFundingFeature",
        [.tca] + modules(.models, .components, .styling, .projectsClient)
    )
    static let userProgressesFeature: Target = .target(
        "UserProgressesFeature",
        [.tca, .nukeUI] + modules(.components, .models, .styling, .userClient)
    )

    static let userChallengeFeature: Target = .target(
        "UserChallengeFeature",
        [.confetti, .tca, .tagged, .navigation] + modules(
            .models,
            .fakes,
            .styling,
            .challengesClient,
            .components,
            .userProgressesFeature
        )
    )

    static let challengeTemplateFeature: Target = .target(
        "ChallengeTemplateFeature",
        [.tca, .tagged, .navigation, .nukeUI] + modules(
            .models,
            .styling,
            .components,
            .fakes,
            .challengesClient,
            .logging,
            .editChallengeFeature
        )
    )
    static let inviteUsersToChallengeFeature: Target = .target(
        "InviteUsersToChallengeFeature",
        [.tca, .nukeUI] + modules(.userClient, .components)
    )
    static let editChallengeFeature: Target = .target(
        "EditChallengeFeature",
        [.tca, .tagged] + modules(.components, .models, .styling, .inviteUsersToChallengeFeature, .userClient)
    )
    static let joinedChallengesFeature: Target = .target(
        "JoinedChallengesFeature",
        [.tca] + modules(.models, .challengesClient, .userChallengeFeature, .components, .styling)
    )

    static let partnerChallengesFeature: Target = .target(
        "PartnerChallengesFeature",
        [.nukeUI, .markdown, .tca] + modules(.models, .components, .styling, .challengesClient, .logging)
    )

    static let projectDetailFeature: Target = .target(
        "ProjectDetailFeature",
        [.tca, .nukeUI, .markdown, .backports] + modules(
            .models,
            .components,
            .styling,
            .projectsClient,
            .projectFundingFeature,
            .logging
        )
    )

    static let offerRedemptionFeature: Target = .target(
        "OfferRedemptionFeature", [.tca, .nukeUI, .markdown] + modules(.models, .styling, .marketplaceClient, .logging)
    )

    static let userFavoritesFeature: Target = .target(
        "UserFavoritesFeature",
        [.asyncAlgorithms, .tca] + modules(
            .models,
            .styling,
            .projectDetailFeature,
            .projectsClient,
            .newsClient,
            .newsFeature
        )
    )

    static let profileEditFeature: Target = .target(
        "ProfileEditFeature",
        [.tca, .navigation, .nukeUI] + modules(
            .models,
            .components,
            .styling,
            .userClient,
            .selectRegionFeature,
            .selectAvatarFeature,
            .logging
        )
    )

    static let projectsFeature: Target = .target(
        "ProjectsFeature",
        [.nukeUI, .tca] + modules(.models, .projectDetailFeature, .styling, .projectsClient, .selectRegionFeature)
    )

    static let trophiesFeature: Target = .target(
        "TrophiesFeature",
        [.confetti, .nukeUI, .tca, .overture, .navigation] +
            modules(.models, .styling, .components, .trophyClient, .logging)
    )

    static let marketplaceFeature: Target = .target(
        "MarketplaceFeature",
        [.tca, .nukeUI] +
            modules(.models, .styling, .components, .selectRegionFeature, .offerRedemptionFeature, .logging)
    )

    static let becomePartner: Target = .target(
        "BecomePartner",
        [.tca, .navigation, .markdown] + modules(.components, .models)
    )
    static let authenticateUserFeature: Target = .target(
        "AuthenticateUserFeature",
        [.tca] + modules(.models, .styling, .components, .userClient, .logging)
    )

    static let surveysFeature: Target = .target(
        "SurveysFeature",
        [.tca, .navigation] + modules(.models, .components, .styling, .surveysClient, .logging)
    )

    static let infoFeature: Target = .target(
        "InfoFeature",
        [.confetti, .tca, .markdown, .navigation] + modules(
            .infoClient,
            .styling,
            .userClient,
            .deepLinking,
            .components,
            .becomePartner,
            .becomeSponsor
        )
    )
    static let registerUserFeature: Target = .target(
        "RegisterUserFeature",
        [.tca] + modules(.models, .userClient, .styling, .components, .selectRegionFeature)
    )
    static let createUserFeature: Target = .target(
        "CreateUserFeature",
        [.tca] + modules(.models, .styling, .userClient, .regionsClient, .logging, .selectRegionFeature)
    )
    static let newUserFeature: Target = .target(
        "NewUserFeature",
        [.tca, .markdown] +
            modules(.models, .styling, .userClient, .components, .createUserFeature, .registerUserFeature)
    )

    static let challengesFeature: Target = .target(
        "ChallengesFeature",
        [.tca, .tagged] + modules(
            .models,
            .fakes,
            .challengeTemplateFeature,
            .styling,
            .components,
            .userChallengeFeature,
            .challengesClient,
            .joinedChallengesFeature,
            .selectRegionFeature,
            .partnerChallengesFeature
        )
    )

    static let profileFeature: Target = .target(
        "ProfileFeature",
        [.tca, .navigation] + modules(
            .models,
            .components,
            .styling,
            .userListFeature,
            .profileEditFeature,
            .trophiesFeature,
            .quizFeature,
            .userFavoritesFeature,
            .registerUserFeature,
            .userClient,
            .deepLinking,
            .alerts
        )
    )

    static let dashboardGridFeature: Target = .target(
        "DashboardGridFeature",
        [.nukeUI, .tca] + modules(
            .models,
            .components,
            .deepLinking,
            .styling,
            .projectsClient,
            .projectDetailFeature,
            .userChallengeFeature,
            .logging
        )
    )

    static let dashboardFeature: Target = .target(
        "DashboardFeature",
        [.tca] + modules(
            .models,
            .components,
            .styling,
            .quizFeature,
            .trophiesFeature,
            .projectsClient,
            .projectDetailFeature,
            .userChallengeFeature,
            .joinedChallengesFeature,
            .surveysFeature,
            .dashboardGridFeature,
            .infoFeature
        )
    )

    static let appFeature: Target = .target(
        "AppFeature",
        [.confetti, .navigation, .tca, .routing] + modules(
            .models, .components, .styling, .challengesFeature, .newsFeature, .marketplaceFeature, .dashboardFeature,
            .projectsFeature, .newUserFeature, .projectsClient, .trophyClient, .profileFeature, .userClient,
            .challengesClient, .infoFeature, .deepLinking, .alerts, .debuggingOverrides
        )
    )

    static let apiClient: Target = .target("APIClient", [.routing] + modules(.models, .logging))
    static let loginFeature: Target = .target(
        "LoginFeature",
        [.tca] + modules(.models, .styling, .appFeature, .newsFeature, .authenticateUserFeature)
    )
    static let mainFeature: Target = .target(
        "MainFeature",
        [.tca, .backports] + modules(.authenticateUserFeature, .appFeature, .loginFeature, .debuggingOverrides)
    )
    static let debuggingOverrides: Target = .target("DebuggingOverrides", [.tca])
}

extension Target.Dependency {
    static let navigation: Self = .product(name: "SwiftUINavigation", package: "swiftui-navigation")
    static let tca: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let tagged: Self = .product(name: "Tagged", package: "swift-tagged")
    static let algorithms: Self = .product(name: "Algorithms", package: "swift-algorithms")
    static let asyncAlgorithms: Self = .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
    static let keychainAccess: Self = .product(name: "KeychainAccess", package: "KeychainAccess")
    static let customDump: Self = .product(name: "CustomDump", package: "swift-custom-dump")
    static let xctDynOverlay: Self = .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
    static let routing: Self = .product(name: "URLRouting", package: "swift-url-routing")
    static let nukeUI: Self = .product(name: "NukeUI", package: "Nuke")
    static let overture: Self = .product(name: "Overture", package: "swift-overture")
    static let markdown: Self = "MarkdownUI"
    static let confetti: Self = "ConfettiSwiftUI"
    static let backports: Self = "SwiftUIBackports"
}

extension Target {
    static func target(
        _ name: String,
        _ dependencies: [Target.Dependency] = [],
        _ resources: [PackageDescription.Resource] = [],
        exclude: [String] = []
    ) -> Target {
        let path: NSString = "\(Context.packageDirectory)/Sources/\(name)/Resources" as NSString
        let withResources = FileManager.default.fileExists(atPath: path.expandingTildeInPath)
        return .target(
            name: name,
            dependencies: dependencies,
            exclude: exclude,
            resources: withResources ? [.process("Resources")] + resources : resources,
            plugins: withResources ? ["SwiftGenPlugin"] : nil
        )
    }

    static func test(
        _ target: Target,
        _ dependencies: [Target.Dependency] = [],
        _ resources: [PackageDescription.Resource] = []
    ) -> Target {
        let targetName = "\(target.name)Tests"
        let path: NSString = "\(Context.packageDirectory)/Tests/\(targetName)/Resources" as NSString
        let withResources = FileManager.default.fileExists(atPath: path.expandingTildeInPath)
        return .testTarget(
            name: targetName,
            dependencies: [.targetItem(name: target.name, condition: nil), .customDump] + dependencies,
            resources: withResources ? !resources.isEmpty ? resources : [.process("Resources")] : resources
        )
    }
}

extension Product {
    static func lib(_ targets: Target...) -> Product {
        .library(name: targets.first!.name, targets: targets.map(\.name))
    }
}

func libraries(_ target: Target...) -> [Product] {
    target.map { Product.lib($0) }
}

func modules(_ target: Target...) -> [PackageDescription.Target.Dependency] {
    target.map { .targetItem(name: $0.name, condition: nil) }
}
