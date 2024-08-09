//
//  Created by Kumpels and Friends on 01.02.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI

public struct BecomePartner: ReducerProtocol {
    public struct State: Equatable {
        @BindingState public var selectedPackage: PartnerPackage = .starter
        var alertState: AlertState<Action>?

        public init(
            selectedPackage: PartnerPackage = .starter,
            alertState: AlertState<BecomePartner.Action>? = nil
        ) {
            self.selectedPackage = selectedPackage
            self.alertState = alertState
        }
    }

    public enum Action: Equatable, BindableAction {
        case dismissSheet
        case binding(BindingAction<State>)
        case openMailTapped
        case dismissAlert
    }

    public init() {}

    public var body: some ReducerProtocolOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .dismissSheet:
                return .none
            case .binding:
                return .none
            case .openMailTapped:
                let string =
                    "mailto:partner@cleema.app?subject=Partnerschaftsanfrage&body=Gew%C3%A4hltes%20Paket%3A%20\(state.selectedPackage.title)"
                guard let url = URL(string: string), UIApplication.shared.canOpenURL(url) else {
                    state.alertState = .sendError()
                    return .none
                }
                UIApplication.shared.open(url)
                return .task {
                    return .dismissSheet
                }
            case .dismissAlert:
                state.alertState = nil
                return .none
            }
        }
    }
}

public enum PartnerPackage: CaseIterable, Identifiable {
    public typealias ID = Tagged<PartnerPackage, String>

    case starter
    case darling
    case learning

    public var id: ID {
        switch self {
        case .starter:
            return "Starter"
        case .darling:
            return "Lieblinge"
        case .learning:
            return "Partner"
        }
    }
}

extension PartnerPackage {
    var title: String {
        switch self {
        case .starter:
            return "Starter"
        case .darling:
            return "Lieblinge"
        case .learning:
            return "Lernen"
        }
    }

    var copy: String {
        switch self {
        case .starter:
            return "Werbekunden"
        case .darling:
            return "Marktplatz"
        case .learning:
            return "Unternehmen"
        }
    }

    var symbol: SwiftUI.Image {
        switch self {
        case .starter:
            return Asset.iconRocket.image
        case .darling:
            return Asset.iconHeart.image
        case .learning:
            return Asset.iconLearning.image
        }
    }

    var features: String {
        switch self {
        case .starter:
            return "Wissen vermitteln, Werte transportieren, Menschen aktivieren. Glaubhafte Werbung bringt euch eurer Zielgruppe näher - und gelingt mit wenig Aufwand. Mit cleemaStarter bucht ihr Werbeleistungen im Rahmen unserer App. Eine einfache Schritt-für-Schritt-Anleitung ermöglicht euch das Sponsoring einer Challenge, die Durchführung einer Kurzbefragung oder den Start eures eigenen Projekts."
        case .darling:
            return "Auf unserem Marktplatz werdet ihr für cleema-Nutzer:innen sichtbar. Ob Restaurant, Modeboutique oder Gesundheitsdienstleistungen - cleemaLieblinge ist eure Möglichkeit, lokale Kund:innen über aktuelle (Einkaufs-)Aktionen zu informieren, die Reichweite eurer Angebote zu vergrößern und den Absatz eurer Produkte zu steigern. Gewinnt eure Stammkundschaft von morgen."
        case .learning:
            return "Erfolgreiche Unternehmen sind nachhaltig. Mit cleemaLernen erhaltet ihr ein intuitives Einstiegstool, das euch dabei hilft, eure Klimabilanz zu verbessern, Mitarbeitende im Prozess mitzunehmen und wirksame wie anschauliche Beispiele für euren Nachhaltigkeitsbericht aufzubauen. Mit cleemaLernen wird Zukunft für alle Beteiligten greifbar."
        }
    }
}

struct PartnerFeature: Hashable {
    var title: String
    var price: String?
}

extension AlertState where Action == BecomePartner.Action {
    static func sendError() -> Self {
        .init(title: TextState("Mail konnte nicht geöffnet werden"), buttons: [
            .cancel(
                TextState("Okay")
            )
        ])
    }
}
