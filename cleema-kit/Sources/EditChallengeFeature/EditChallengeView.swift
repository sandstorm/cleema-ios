//
//  Created by Kumpels and Friends on 24.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import Foundation
import InviteUsersToChallengeFeature
import Models
import NukeUI
import Styling
import SwiftUI

public struct EditChallengeView: View {
    let store: StoreOf<EditChallenge>

    enum Field: Hashable {
        case title, teaserText, description
    }

    @FocusState var focussedField: Field?

    public init(store: StoreOf<EditChallenge>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading) {
                    Text(L10n.Edit.hint) 
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Text(L10n.Edit.Hint.saving)

                    GroupBox {
                        VStack(alignment: .leading) {
                            if let image = viewStore.challenge.image?.image {
                                LazyImage(url: image.url, resizingMode: .aspectFill)
                                    .frame(height: 225)
                                Spacer()
                            }
                            
                            Text(L10n.Form.Section.Title.label.uppercased())
                                .font(.montserratBold(style: .title, size: 12))

                            TextField(
                                L10n.Form.Section.Title.Textfield.Title.label,
                                text: viewStore.binding(\.$challenge.title)
                            )
                            .focused($focussedField, equals: .title)

                            Divider()

                            Text(L10n.Form.Section.Teaser.label.uppercased())
                                .font(.montserratBold(style: .title, size: 12))
                                .padding(.top)

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: viewStore.binding(\.$challenge.teaserText))
                                    .focused($focussedField, equals: .teaserText)
                                    .padding([.top, .horizontal], -5)
                                if viewStore.challenge.teaserText.isEmpty {
                                    Text(L10n.Form.Section.Teaser.label)
                                        .foregroundColor(.lightGray)
                                        .allowsHitTesting(false)
                                        .padding(.vertical, 2)
                                }
                            }

                            Divider()

                            Text(L10n.Form.Section.Description.label.uppercased())
                                .font(.montserratBold(style: .title, size: 12))
                                .padding(.top)

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: viewStore.binding(\.$challenge.description))
                                    .focused($focussedField, equals: .description)
                                    .padding([.top, .horizontal], -5)

                                if viewStore.challenge.description.isEmpty {
                                    Text(L10n.Form.Section.Description.label)
                                        .foregroundColor(.lightGray)
                                        .allowsHitTesting(false)
                                        .padding(.vertical, 2)
                                }
                            }
                            .frame(height: 200)

                            Divider()

                            Text(L10n.Form.Section.Details.label.uppercased())
                                .font(.montserratBold(style: .title, size: 12))
                                .padding(.top)
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text(L10n.Form.Section.Details.Picker.Interval.label)

                                Spacer()

                                Picker(
                                    L10n.Form.Section.Details.Picker.Interval.label,
                                    selection: viewStore.binding(\.$challenge.interval)
                                ) {
                                    ForEach(Challenge.Interval.allCases) {
                                        Text($0.label)
                                            .tag($0)
                                    }
                                }
                                .labelsHidden()
                            }

                            DatePicker(
                                L10n.Form.Section.Details.Picker.Start.label,
                                selection: viewStore.binding(\.$challenge.startDate),
                                in: Date.now ... viewStore.challenge.endDate,
                                displayedComponents: .date
                            )

                            DatePicker(
                                L10n.Form.Section.Details.Picker.End.label,
                                selection: viewStore.binding(\.$challenge.endDate),
                                in: viewStore.challenge.startDate...,
                                displayedComponents: .date
                            )

                            Toggle(
                                L10n.Form.Section.Details.Toggle.IsPublic.label,
                                isOn: viewStore.binding(\.$challenge.isPublic).animation()
                            )
                            .toggleStyle(.switch)
                            .disabled(!viewStore.state.canInviteFriends)
                            .tint(.action)
                            
                            if !viewStore.state.canInviteFriends {
                                Text(L10n.Form.Section.Details.InviteFriends.hint)
                                    .font(.montserrat(style: .caption, size: 12))
                            }

                            if viewStore.challenge.isPublic {
                                Text(L10n.Form.Section.Details.IsPublic.hint)
                                    .font(.montserrat(style: .caption, size: 12))
                            }
                        }
                    }
                }
                .padding()
            }
            .background {
                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: \.inviteUsersToChallengeState,
                            action: EditChallenge.Action.inviteUsersToChallenge
                        ),
                        then: InviteUsersToChallengeView.init(store:)
                    ),
                    isActive: viewStore.binding(
                        get: \.showsInviteUsers,
                        send: EditChallenge.Action.setNavigation(isActive:)
                    )
                ) {
                    EmptyView()
                }
            }
            .onChange(of: viewStore.shouldEndEditing) {
                if $0 {
                    focussedField = nil
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewStore.send(.nextButtonTapped)
                    } label: {
                        Text(
                            viewStore.state.challenge.isPublic ? L10n.Button.next : L10n.Button.save
                        )
                    }
                    .disabled(viewStore.isComplete == false)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewStore.send(.cancelButtonTapped)
                    } label: {
                        Text(L10n.Button.cancel)
                    }
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        focussedField = nil
                    } label: {
                        Text(L10n.Button.Keyboard.done)
                            .font(.montserratBold(style: .title, size: 16))
                            .foregroundColor(.action)
                    }
                }
            }
            .task {
                await viewStore.send(.task).finish()
            }
        }
        .background(Color.accent)
        .navigationTitle(L10n.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

extension Challenge.Interval {
    var label: String {
        switch self {
        case .daily:
            return L10n.Form.Section.Details.Picker.Interval.daily
        case .weekly:
            return L10n.Form.Section.Details.Picker.Interval.weekly
        }
    }
}

struct CreateChallenge_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditChallengeView(store: .init(
                initialState: .init(challenge: .fake()),
                reducer: EditChallenge()
            ))
        }
        .cleemaStyle()
    }
}
