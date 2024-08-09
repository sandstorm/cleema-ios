//
//  Created by Kumpels and Friends on 18.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import MapKit
import MarkdownUI
import Models
import NukeUI
import ProjectFundingFeature
import Styling
import SwiftUI
import SwiftUIBackports

public struct ProjectDetailView: View {
    let store: StoreOf<ProjectDetail>

    var isPresentedInSheet: Bool

    public init(store: StoreOf<ProjectDetail>, isPresentedInSheet: Bool = false) {
        self.store = store
        self.isPresentedInSheet = isPresentedInSheet
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        GroupBox {
                            HStack(alignment: .top) {
                                Text(L10n.Project.Detail.Phase.label)
                                    .bold()

                                Spacer()

                                Text(viewStore.project.phaseText)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        .groupBoxStyle(viewStore.project.phase.groupBoxStyle)

                        IfLetStore(store.scope(state: \.involvementState), then: InvolvementGoalView.init(store:))

                        IfLetStore(
                            store
                                .scope(state: \.fundingState, action: ProjectDetail.Action.funding)
                        ) { fundingStore in
                            ProjectFundingView(store: fundingStore)
                        }

                        Divider()

                        Markdown(viewStore.project.description)
                            .font(.montserrat(style: .body, size: 14))
                            .accentColor(.action)

                        GroupBox {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(L10n.Project.Detail.Partner.Link.label)
                                    .font(.montserrat(style: .footnote, size: 12))

                                Link(destination: viewStore.project.partner.url) {
                                    Text(viewStore.project.partner.title)
                                        .font(.montserratBold(style: .headline, size: 16))
                                        .multilineTextAlignment(.leading)
                                }
                                .foregroundColor(.action)

                                if let partnerDescription = viewStore.project.partner.description,
                                   let attributedString =
                                   try? AttributedString(markdown: Data(partnerDescription.utf8))
                                {
                                    Text(attributedString)
                                        .accentColor(.action)
                                        .font(.montserrat(style: .body, size: 14))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .groupBoxStyle(.partner)

                        Divider()

                        if let projectLocation = viewStore.project.location {
                            Button {
                                let mapItem = MKMapItem(
                                    placemark: MKPlacemark(
                                        coordinate: projectLocation.coordinate,
                                        addressDictionary: nil
                                    )
                                )
                                mapItem.name = projectLocation.title
                                mapItem
                                    .openInMaps(
                                        launchOptions: [
                                            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                                        ]
                                    )
                            } label: {
                                Map(
                                    coordinateRegion: .constant(
                                        MKCoordinateRegion(
                                            center: projectLocation.coordinate,
                                            span: MKCoordinateSpan(
                                                latitudeDelta: 0.02,
                                                longitudeDelta: 0.02
                                            )
                                        )
                                    ),
                                    interactionModes: [],
                                    annotationItems: [projectLocation]
                                ) { location in
                                    MapMarker(coordinate: location.coordinate, tint: Color.dimmed)
                                }
                                .frame(height: 180)
                            }
                        }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 16) {
                        if let image = viewStore.project.image {
                            LazyImage(url: image.url, resizingMode: .aspectFill)
                                .frame(height: 225)
                        }

                        HStack(alignment: .firstTextBaseline) {
                            Text(viewStore.project.title)
                                .font(.montserratBold(style: .headline, size: 20))

                            Spacer()

                            Button {
                                viewStore.send(.favoriteTapped, animation: .default)
                            } label: {
                                Image(systemName: viewStore.project.isFaved ? "star.fill" : "star")
                                    .foregroundColor(.action)
                            }
                            .disabled(viewStore.isLoading)
                        }
                    }
                }
                .padding()
            }
            .background {
                if isPresentedInSheet {
                    Color.accent.ignoresSafeArea()
                } else {
                    ScreenBackgroundView()
                }
            }
            .alert(store.scope(state: \.alertState), dismiss: .dismissAlert)
        }
    }
}

extension Project {
    var phaseText: String {
        switch phase {
        case .pre:
            if goal == .information {
                return L10n.Project.Detail.Phase.preInformation
            } else {
                return L10n.Project.Detail.Phase.pre(startDate.formatted(date: .numeric, time: .shortened))
            }
        case .within:
            return L10n.Project.Detail.Phase.active
        case .post:
            return L10n.Project.Detail.Phase.finished
        case .cancelled:
            return L10n.Project.Detail.Phase.cancelled
        }
    }
}

extension Project.Phase {
    var groupBoxStyle: ColoredBackgroundGroupBoxStyle {
        switch self {
        case .pre:
            return .init(backgroundColor: .light, foregroundColor: .defaultText)
        case .within:
            return .init(backgroundColor: .dimmed, foregroundColor: .white)
        case .post, .cancelled:
            return .init(backgroundColor: .finishedProject, foregroundColor: .white)
        }
    }
}

extension GroupBoxStyle where Self == ColoredBackgroundGroupBoxStyle {
    static var partner: Self { .init(backgroundColor: .light, foregroundColor: .defaultText) }
}

// MARK: - Preview

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailView(
            store: .init(
                initialState: .init(
                    project: Array<Project>.demo.randomElement()!,
                    isLoading: false
                ),
                reducer: ProjectDetail()
            )
        )
        .groupBoxStyle(.plain)
        .cleemaStyle()
    }
}
