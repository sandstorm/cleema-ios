//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import MarkdownUI
import Models
import NukeUI
import Styling
import SwiftUI

struct PartnerChallengeView: View {
    let store: StoreOf<PartnerChallenge>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        GroupBox {
                            HStack(alignment: .top) {
                                Text(L10n.Start.label)
                                    .bold()

                                Spacer()

                                Text(viewStore.challenge.startDate.formatted(date: .numeric, time: .omitted))
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        HStack {
                            PersonsJoinedView(count: viewStore.challenge.numberOfUsersJoined)

                            Spacer()

                            if (viewStore.challenge.endDate > NSDate() as Date) {
                                Button {
                                    viewStore.send(.joinLeaveButtonTapped)
                                } label: {
                                    ZStack {
                                        let buttonLabel: String = viewStore.challenge.isJoined ? L10n.Button.Leave
                                            .label : L10n.Button.Join.label
                                        // Following hidden Texts set the width of the buttons
                                        Text(L10n.Button.Join.label).hidden()
                                        Text(L10n.Button.Leave.label).hidden()

                                        if viewStore.isLoading {
                                            ProgressView()
                                                .controlSize(.small)
                                                .padding(.leading, 2)
                                        } else {
                                            Text(buttonLabel)
                                        }
                                    }
                                }
                                .disabled(viewStore.isLoading)
                            } else {
                                Text(L10n.Item.Date.Label.finished)
                            }
                        }
                        if case .collective(_) = viewStore.challenge.kind {
                            Divider()
                                .padding(.top, 24)
                            
                            Text(L10n.Progress.Bar.Label.collective)
                                .font(.montserrat(style: .footnote, size: 12))
                            CollectiveProgressView(userChallenge: JoinedChallenge(challenge: viewStore.challenge))
                                .font(.montserrat(style: .footnote, size: 12))
                        }

                        Divider()
                            .padding(5)

                        Markdown(viewStore.challenge.description)
                            .font(.montserrat(style: .body, size: 14))
                            .accentColor(.action)

                        if let partner = viewStore.challenge.sponsor {
                            GroupBox {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text(L10n.Partner.label)
                                            .font(.montserrat(style: .footnote, size: 12))

                                        Spacer()

                                        if let image = viewStore.challenge.partner?.logo {
                                            LazyImage(url: image.url, resizingMode: .aspectFit)
                                                .frame(width: 100, height: 36, alignment: .leading)
//                                                .blendMode(.multiply)
                                        }
                                    }

                                    Link(destination: partner.url) {
                                        Text(partner.title)
                                            .font(.montserratBold(style: .headline, size: 16))
                                            .multilineTextAlignment(.leading)
                                    }
                                    .foregroundColor(.action)
                                    .buttonStyle(.plain)

                                    if let partnerDescription = partner.description,
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
                        }
                    }
                    .groupBoxStyle(.challenge)
                    .buttonStyle(.action)
                } label: {
                    if let image = viewStore.challenge.image?.image {
                        LazyImage(url: image.url, resizingMode: .aspectFill)
                            .frame(height: 225)
                    }

                    Text(viewStore.challenge.title)
                        .font(.montserratBold(style: .headline, size: 20))
                }
                .padding()
            }
            .background(ScreenBackgroundView())
        }
    }
}

extension GroupBoxStyle where Self == ColoredBackgroundGroupBoxStyle {
    static var challenge: Self { .init(backgroundColor: .light, foregroundColor: .defaultText) }
}

struct PartnerChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PartnerChallengeView(store: .init(
                initialState: .init(challenge: .fake(kind: .partner(.fake()))),
                reducer:
                PartnerChallenge()
            ))
        }
    }
}
