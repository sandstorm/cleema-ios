//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation
import Models
import SwiftUI

public extension Image {
    static let demo1: Self = Image("demoProjectIcon1", bundle: .module)
    static let demo2: Self = Image("demoProjectIcon2", bundle: .module)
}

public extension UIImage {
    static let demo1: UIImage = .init(named: "demoProjectIcon1", in: .module, with: nil)!
    static let demo2: UIImage = .init(named: "demoProjectIcon2", in: .module, with: nil)!
}

public extension Array where Element == Project {
    static let involvement: Self = [
        .init(
            id: .init(rawValue: .init(uuidString: "7895478C-C6F2-4D4E-ACE5-73341F32227A")!),
            title: "Essbares öffentliches Stadtgrün",
            summary:
            """
            Grün und essbar statt grau und öde. Der Stadtgärten e.V. macht aus öffentlichen Brachflächen grüne Oasen mit essbaren Pflanzen. Fühl dich eingeladen zum Planen, Anlegen, Pflegen und Ernten.

            In diesen Stadtgärten kannst du gemeinsam mit Gleichgesinnten aktiv sein:
            - Albertgarten am Hafen
            - Hügelbeet Stadtgarten im Alaunpark
            - Grünzug Gehestraße
            - Pflanzkübel Hechtviertel
            - Infogarten Waldschlößchenbrücke
            - SLUB Text Lab
            - Baumscheibe Zwickauer Straße
            """,
            description: "Unter www.stadtgaerten.org erfährst du, was es gerade zu tun gibt und wo deine helfende Hand gebraucht wird. Werkzeug, Gartengeräte und Saatgut sind vorhanden. Du kannst auch gern weitere öffentliche Flächen mit Potenzial vorschlagen.",
            image: nil,
            teaserImage: nil,
            startDate: .momentOn(day: 1, month: 9, year: 2_022),
            partner: .fake(title: "Stadtgärten e.V.", url: .init(string: "https://www.stadtgaerten.org")!),
            region: .dresden,
            location: .dresden,
            goal: .involvement(currentParticipants: 0, maxParticipants: 10_000, joined: false),
            phase: .pre
        ),
        .init(
            id: .init(rawValue: .init(uuidString: "F5A80313-EB14-4E29-B582-A1D623714DC3")!),
            title: "Pinke Hände",
            summary:
            """
            Kippe weggeschnippt und gut? Mitnichten! Zigarettenstummel sind giftiger Sondermüll, der obendrein unsere Stadt verschandelt. Eine Initiative junger Menschen sammelt achtlos weggeworfene Kippen ein, um zu zeigen, dass es auch besser geht. Die „Pinken Hände“ sind jeden Freitag um 17 Uhr an einem Ort in der Stadt aktiv.
            """,
            description: "Schau gerne in den Instagram- oder Telegram-Kanal von @pinkehaende. Dort erhältst du mehr Infos.",
            image: nil,
            teaserImage: nil,
            startDate: .momentOn(day: 22, month: 8, year: 2_022),
            partner: .fake(
                title: "Initiative Pinke Hände",
                url: .init(string: "https://www.instagram.com/pinkehaende")!
            ),
            region: .dresden,
            location: .dresden,
            goal: .involvement(currentParticipants: 0, maxParticipants: 10_000, joined: false),
            phase: .pre
        ),
        .init(
            id: .init(rawValue: .init(uuidString: "BC58A2E6-3F7C-4DBC-9C5F-28525C09D27A")!),
            title: "Cleanup Leipzig",
            summary:
            """
            Komm, wir gehen Müll sammeln! Cleanups sind Aufräumaktionen, bei denen Menschen zusammenkommen und ihre Umgebung von Müll befreien - einen Spielplatz, eine Grünfläche oder einen anderen öffentlichen Ort.
            Beim Müll wegräumen schärft sich dein Bewusstsein für ein schönes, sauberes Umfeld. Du kommst in den Austausch mit anderen und siehst vielleicht auch mal eine Ecke Leipzigs, die du noch nicht kennst.
            """,
            description: "Mindestens einmal im Monat sind wir irgendwo in Leipzig unterwegs. Informier dich auf www.cleanupleipzig.de oder auf Instagram @cleanupleipzig.",
            image: nil,
            teaserImage: nil,
            startDate: .momentOn(day: 1, month: 10, year: 2_022),
            partner: .fake(
                title: "Cleanup Leipzig gemeinnützige UG",
                url: .init(string: "https://www.cleanupleipzig.de")!
            ),
            region: .leipzig,
            location: .leipzig,
            goal: .involvement(currentParticipants: 0, maxParticipants: 10_000, joined: false),
            phase: .pre
        )
    ]

    static let funding: Self = [
        .init(
            id: .init(rawValue: .init(uuidString: "0FCD69FC-8E52-4103-8C8E-AD9EEA85EE50")!),
            title: "Wiederaufbau Nationalpark Sächsische Schweiz",
            summary:
            """
            Blutet dir auch das Herz, wenn du die verkohlten Wälder in der Sächsischen Schweiz siehst? Der Nationalpark als Rückzugsort für Natur, Tier und Mensch ist schwer geschädigt und braucht unsere Hilfe.

            Unterstütze den Wiederaufbau der einmaligen Pflanzen- und Tierwelt. Außerdem gilt es, besser vorbereitet zu sein, um Waldbrände künftig effektiver bekämpfen zu können. Beispielsweise sollen neue Wasserrückhaltemöglichkeiten gebaut werden.
            """,
            description: "Unterstütze die Renaturierung des Nationalparks mit deiner Spende. Die Gelder fließen zu 100% in den Wiederaufbau und Erhalt der Nationalparkregion. Die Entscheidung, welche Maßnahmen umgesetzt werden, findet nach einer vollständigen Einschätzung der Lage statt. Wir werden hier darüber informieren.",
            image: nil,
            teaserImage: nil,
            startDate: .momentOn(day: 17, month: 10, year: 2_022),
            partner: .fake(
                title: "Förderverein Nationalparkfreunde Sächsische Schweiz e.V.",
                url: .init(string: "https://waldbrand-osterzgebirge.de")!
            ),
            region: .pirna,
            location: .pirna,
            goal: .funding(currentAmount: 0, totalAmount: 10_000_000),
            phase: .pre
        ),
        .init(
            id: .init(rawValue: .init(uuidString: "2B345D42-4C53-4BD8-B3BF-38B794CC99BE")!),
            title: "Metro_polis",
            summary:
            """
            Im Normalfall ist eine Straßenbahnfahrt eine ziemlich schweigsame Angelegenheit. Doch es geht auch anders: Einmal pro Woche bringt das Projekt metro_polis wildfremde Menschen, die zufällig in derselben Bahn sitzen, miteinander ins Gespräch. Angeleitet von einem ausgebildeten Moderationsteam sprechen die Fahrgäste über Themen, die sie gerade bewegen.

            Im Mittelpunt steht die Frage, wie gesellschaftlicher Diskurs konstruktiv gelingen kann. Die Erfahrungen sind fast durchweg positiv. Viele Fahrgäste machen mit – vom obdachlosen Jugendlichen bis zum Referenten des Innenministeriums. Die Moderator:innen führen Dialoge mit bis zu drei Personen. Auch wenn es häufig um kontroverse Themen geht, gelingt ein respektvoller Austausch.
            """,
            description: "Unterstütze die Diskussionsplattform in der Straßenbahn mit deiner Spende. Die Gelder werden hauptsächlich für die Ausbildung der ehrenamtlichen Moderator:innen benötigt.",
            image: nil,
            teaserImage: nil,
            startDate: .momentOn(day: 22, month: 10, year: 2_022),
            partner: .fake(title: "Metro_polis n.e.V.", url: .init(string: "https://metro-polis.online")!),
            region: .dresden,
            location: .dresden,
            goal: .funding(currentAmount: 0, totalAmount: 50_000),
            phase: .pre
        )
    ]

    static let demo: Self = .involvement + .funding
}
