//
//  Created by Kumpels and Friends on 05.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Components
import NukeUI
import ProjectDetailFeature
import Styling
import SwiftUI

public struct ProjectRowView: View {
    let store: StoreOf<ProjectDetail>

    public init(store: StoreOf<ProjectDetail>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            GroupBox {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(viewStore.project.summary)
                            .lineLimit(5)
                            .font(.montserrat(style: .body, size: 14))

                        Spacer()

                        if viewStore.project.goal != .information {
                            LabeledContentView(
                                L10n.Project.Start.label,
                                value: viewStore.project.startDate.formatted(date: .numeric, time: .omitted)
                            )
                        }
                    }

                    Spacer()

                    if let teaserImage = viewStore.project.teaserImage {
                        LazyImage(url: teaserImage.url, resizingMode: .aspectFit)
                            //.frame(width: teaserImage.width, height: teaserImage.height)
                            // set fixed width/height so images cannot be too big for the container
                            // since resizingMode: .aspectFit, it sizes up to either width: 165 or height: 156
                            // values taken from previous teaser images
                            .frame(width: 165, height: 156)
                    }
                }

                Divider()

                LabeledContentView(
                    horizontalFixed: false,
                    verticalFixed: true,
                    L10n.Project.Partner.label,
                    value: viewStore.project.partner.title
                )
            } label: {
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
                }
            }
        }
    }
}

// MARK: - Preview

struct ProjectRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ProjectRowView(
                        store: .init(
                            initialState: .init(
                                project: .fake(teaserImage: .fake(width: 150, height: 120)),
                                isLoading: false
                            ),
                            reducer: ProjectDetail()
                        )
                    )
                    ProjectRowView(
                        store: .init(
                            initialState: .init(
                                project: .fake(teaserImage: .fake(width: 150, height: 120)),
                                isLoading: false
                            ),
                            reducer: ProjectDetail()
                        )
                    )
                    ProjectRowView(
                        store: .init(
                            initialState: .init(
                                project: .fake(teaserImage: .fake(width: 150, height: 120)),
                                isLoading: false
                            ),
                            reducer: ProjectDetail()
                        )
                    )
                    ProjectRowView(
                        store: .init(
                            initialState: .init(
                                project: .fake(teaserImage: .fake(width: 150, height: 120)),
                                isLoading: false
                            ),
                            reducer: ProjectDetail()
                        )
                    )
                }
                .padding()
            }
            .background(ScreenBackgroundView())
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
        }
        .cleemaStyle()
        .previewLayout(.sizeThatFits)
    }
}
