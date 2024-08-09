//
//  Created by Kumpels and Friends on 08.02.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import BecomeSponsorClient
import Components
import ComposableArchitecture
import Models
import SwiftUI

public struct BecomeSponsor: ReducerProtocol {
    public struct State: Equatable {
        public enum Step {
            case selectPackage
            case enterData
            case confirm
            case thanks
        }

        public var step: Step = .selectPackage
        @BindingState public var selectedPackage: SponsorPackage = .fan
        @BindingState public var sponsorData: SponsorData = .init()
        @BindingState var isSEPAConfirmed: Bool = false
        var isSending: Bool = false
        var alertState: AlertState<Action>?

        public var nextButtonIsDisabled: Bool {
            switch step {
            case .selectPackage:
                return false
            case .enterData:
                return sponsorData.isInvalid
            case .confirm:
                return !isSEPAConfirmed || isSending
            case .thanks:
                return false
            }
        }

        #if DEBUG
        public init(
            step: BecomeSponsor.State.Step = .selectPackage,
            selectedPackage: SponsorPackage = .fan,
            sponsorData: SponsorData = .debug,
            isSEPAConfirmed: Bool = false,
            isSending: Bool = false,
            alertState: AlertState<BecomeSponsor.Action>? = nil
        ) {
            self.step = step
            self.selectedPackage = selectedPackage
            self.sponsorData = sponsorData
            self.isSEPAConfirmed = isSEPAConfirmed
            self.isSending = isSending
            self.alertState = alertState
        }
        #else
        public init(
            step: BecomeSponsor.State.Step = .selectPackage,
            selectedPackage: SponsorPackage = .fan,
            sponsorData: SponsorData = .init(),
            isSEPAConfirmed: Bool = false,
            isSending: Bool = false,
            alertState: AlertState<BecomeSponsor.Action>? = nil
        ) {
            self.step = step
            self.selectedPackage = selectedPackage
            self.sponsorData = sponsorData
            self.isSEPAConfirmed = isSEPAConfirmed
            self.isSending = isSending
            self.alertState = alertState
        }
        #endif
    }

    public enum Action: Equatable, BindableAction {
        case dismissSheet
        case binding(BindingAction<State>)
        case nextButtonTapped
        case changePackageTapped
        case changeSponsorDataTapped
        case dataResponse(TaskResult<Bool>)
        case dismissAlert
    }

    @Dependency(\.becomeSponsorClient.addMembership) private var addMembership

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .dismissSheet:
                return .none
            case .changePackageTapped:
                state.step = .selectPackage
                return .none
            case .changeSponsorDataTapped:
                state.step = .enterData
                return .none
            case .nextButtonTapped:
                switch state.step {
                case .selectPackage:
                    state.step = .enterData
                    return .none
                case .enterData:
                    state.step = .confirm
                    return .none
                case .confirm:
                    state.isSending = true
                    return .task { [packageID = state.selectedPackage.id, sponsorData = state.sponsorData] in
                        await .dataResponse(TaskResult {
                            try await addMembership(packageID, sponsorData)
                            return true
                        })
                    }
                    .animation(.default)
                case .thanks:
                    return .none
                }
            case .dataResponse(.success):
                state.step = .thanks
                state.isSending = false
                return .none
            case let .dataResponse(.failure(error)):
                state.isSending = false
                state.alertState = .sendError(error)
                return .none
            case .binding:
                return .none
            case .dismissAlert:
                state.alertState = nil
                return .none
            }
        }
    }
}

import ContactsUI
extension SponsorData {
    var fullName: String {
        let formatter = CNContactFormatter()
        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName
        return formatter.string(from: contact) ?? ""
    }

    var address: String {
        let formatter = CNPostalAddressFormatter()
        let address = CNMutablePostalAddress()
        address.street = streetAndHouseNumber
        address.postalCode = postalCode
        address.city = city
        return formatter.string(from: address)
    }
}

public extension SponsorData {
    static let debug: Self = .init(
        firstName: "Hans-Bernd",
        lastName: "Cleema",
        streetAndHouseNumber: "Cleemastraße 1",
        postalCode: "51234",
        city: "Cleemadorf",
        iban: "DE91100000000123456789",
        bic: "MARKDEF1100"
    )
}

extension SponsorPackage {
    var title: String {
        switch self {
        case .fan:
            return "Fan"
        case .maker:
            return "Macher"
        case .love:
            return "Liebe"
        }
    }

    var copy: String {
        switch self {
        case .fan:
            return "Für alle, die etwas bewegen wollen."
        case .maker:
            return "Für alle, die energiegeladen sind."
        case .love:
            return "Für alle, die etwas mehr wollen."
        }
    }

    var symbol: SwiftUI.Image {
        switch self {
        case .fan:
            return Asset.iconFan.image
        case .maker:
            return Asset.iconMaker.image
        case .love:
            return Asset.iconLove.image
        }
    }

    var features: String {
        switch self {
        case .fan:
            return "In unserem jährlichen cleema Report zeigen wir dir, wie sich unser Startup entwickelt und was hinter den Kulissen geschieht. Du erfährst, wofür wir deinen monatlichen Beitrag verwenden und was wir damit bewirken. Wir berichten über unsere nächsten Ziele, die wir gemeinsam mit der cleema Community erreichen wollen. Unser ausführlicher Jahresbericht erreicht dich im PDF-Format.\n\n#### Werde als cleemaFan sichtbar\nIn deinem Profil wirst du als Fördermitglied sichtbar. So zeigst du dein Engagement in der Community."
        case .maker:
            return "Als cleema Macher kannst du an Umfragen und Votings teilnehmen und damit die Weiterentwicklung unserer cleema App mitbestimmen. Unabhängig von deiner Teilnahme erhältst du die Umfrageergebnisse und erfährst, welche Entscheidungen auf dieser Basis getroffen werden.\n\n#### Sichere dir exklusive Informationen\nIn unserem jährlichen cleema Report zeigen wir dir, wie sich unser Startup entwickelt und was hinter den Kulissen geschieht. Du erfährst, wofür wir deinen monatlichen Beitrag verwenden und was wir damit bewirken. Wir berichten über unsere nächsten Ziele, die wir gemeinsam mit der cleema Community erreichen wollen. Unser ausführlicher Jahresbericht erreicht dich im PDF-Format.\n\n#### Werde als cleemaFan sichtbar\nIn deinem Profil wirst du als Fördermitglied sichtbar. So zeigst du dein Engagement in der Community."
        case .love:
            return "Unser Liebesgeschenk an dich ist eine Überraschungskiste, die wir dir jährlich zusenden. Freue dich auf nachhaltig produzierte Produkte.\n\nDu kannst du an Umfragen und Votings teilnehmen und damit die Weiterentwicklung unserer cleema App mitbestimmen. Unabhängig von deiner Teilnahme erhältst du die Umfrageergebnisse und erfährst, welche Entscheidungen auf dieser Basis getroffen werden.\n\n#### Bestimme mit\nDu kannst du an Umfragen und Votings teilnehmen und damit die Weiterentwicklung unserer cleema App mitbestimmen. Unabhängig von deiner Teilnahme erhältst du die Umfrageergebnisse und erfährst, welche Entscheidungen auf dieser Basis getroffen werden.\n\n#### Sichere dir exklusive Informationen\nIn unserem jährlichen cleema Report zeigen wir dir, wie sich unser Startup entwickelt und was hinter den Kulissen geschieht. Du erfährst, wofür wir deinen monatlichen Beitrag verwenden und was wir damit bewirken. Wir berichten über unsere nächsten Ziele, die wir gemeinsam mit der cleema Community erreichen wollen. Unser ausführlicher Jahresbericht erreicht dich im PDF-Format.\n\n#### Werde als cleemaFan sichtbar\nIn deinem Profil wirst du als Fördermitglied sichtbar. So zeigst du dein Engagement in der Community."
        }
    }

    var priceInEuro: Int {
        switch self {
        case .fan:
            return 5
        case .maker:
            return 10
        case .love:
            return 25
        }
    }
}

extension AlertState where Action == BecomeSponsor.Action {
    static func sendError(_ error: Error) -> Self {
        .init(title: TextState(error.localizedDescription), buttons: [
            .cancel(
                TextState("Okay")
            )
        ])
    }
}
