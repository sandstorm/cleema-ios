//
//  Created by Kumpels and Friends on 27.10.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import Foundation

/*
 {
 "title": "Essbares öffentliches Stadtgrün",
 "summary": "Grün und essbar statt grau und öde. Der Stadtgärten e.V. macht aus öffentlichen Brachflächen grüne Oasen mit essbaren Pflanzen. Fühl dich eingeladen zum Planen, Anlegen, Pflegen und Ernten.\n\nIn diesen Stadtgärten kannst du gemeinsam mit Gleichgesinnten aktiv sein:\n- Albertgarten am Hafen\n- Hügelbeet Stadtgarten im Alaunpark\n- Grünzug Gehestraße\n- Pflanzkübel Hechtviertel\n- Infogarten Waldschlößchenbrücke\n- SLUB Text Lab\n- Baumscheibe Zwickauer Straße",
 "description": "Unter www.stadtgaerten.org erfährst du, was es gerade zu tun gibt und wo deine helfende Hand gebraucht wird. Werkzeug, Gartengeräte und Saatgut sind vorhanden. Du kannst auch gern weitere öffentliche Flächen mit Potenzial vorschlagen.",
 "startDate": "2022-10-12T00:00:00.000Z",
 "createdAt": "2022-10-10T09:24:02.001Z",
 "updatedAt": "2022-10-24T14:39:40.952Z",
 "publishedAt": "2022-10-10T09:28:05.334Z",
 "locale": "de-DE",
 "goalType": "involvement",
 "phase": "pre",
 "conclusion": "Test",
 "uuid": "b29b5e4e-fb63-42f1-b2f1-a4aa124a9af4",
 "region": null,
 "partner": {
 "title": "Stadtgärten e.V.",
 "url": "https://www.stadtgaerten.org",
 "createdAt": "2022-10-10T09:27:17.993Z",
 "updatedAt": "2022-10-17T11:57:22.013Z",
 "publishedAt": "2022-10-10T09:28:01.191Z",
 "uuid": "d1b3e8f3-0467-474e-9adb-8bd5fb3fb9ce"
 },
 "goalInvolvement": {
 "currentParticipants": 0,
 "maxParticipants": 10000
 },
 "goalFunding": {
 "currentAmount": 0,
 "totalAmount": 0.01
 },
 "isFaved": false,
 "joined": false
 }
 */

struct ProjectResponse: Codable {
    enum GoalType: String, Codable {
        case involvement
        case funding
        case information
    }

    enum Phase: String, Codable {
        case pre, running, post, cancelled
    }

    var title: String
    var summary: String
    var description: String
    var startDate: Date
    var goalType: GoalType
    var uuid: UUID
    var partner: PartnerResponse?
    var isFaved: Bool
    var joined: Bool
    var phase: Phase
    var conclusion: String?
    var region: RegionResponse
    var goalInvolvement: Involvement?
    var goalFunding: Funding?
    var location: LocationResponse?
    var image: ImageResponse?
    var teaserImage: ImageResponse?
}

struct Involvement: Codable {
    var currentParticipants: Int
    var maxParticipants: Int
}

struct Funding: Codable {
    var currentAmount: Double
    var totalAmount: Double
}

struct LocationResponse: Codable {
    struct Coordinates: Codable {
        var latitude: Double
        var longitude: Double
    }

    var title: String
    var coordinates: Coordinates
}
