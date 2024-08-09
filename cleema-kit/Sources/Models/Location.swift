//
//  Created by Kumpels and Friends on 18.08.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import CoreLocation
import Foundation
import Tagged

public struct Location: Identifiable, Hashable, Codable {
    public init(id: ID = .init(rawValue: .init()), title: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
    }

    public typealias ID = Tagged<Location, UUID>

    public var id: ID = .init(rawValue: .init())
    public var title: String
    public var coordinate: CLLocationCoordinate2D

    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.coordinate.latitude == rhs.coordinate.latitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

public extension Location {
    static let dresden: Self = .init(
        id: .init(rawValue: .init(uuidString: "EF83FFE8-6632-4F59-842F-F121B2E12B18")!),
        title: "Dresden",
        coordinate: .init(latitude: 51.0581646966131, longitude: 13.74131897017187)
    )
    static let leipzig: Self = .init(
        id: .init(rawValue: .init(uuidString: "4B55F3E6-5491-4849-BF26-21774904550C")!),
        title: "Leipzig",
        coordinate: .init(latitude: 51.33920794898677, longitude: 12.372524854876929)
    )
    static let pirna: Self = .init(
        id: .init(rawValue: .init(uuidString: "CF14B889-E90C-4916-8AC0-204E5E74DAE8")!),
        title: "Pirna",
        coordinate: .init(latitude: 50.962517, longitude: 13.941917)
    )
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case lat, lon
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .lat)
        try container.encode(longitude, forKey: .lon)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            latitude: container.decode(CLLocationDegrees.self, forKey: .lat),
            longitude: try container.decode(CLLocationDegrees.self, forKey: .lon)
        )
    }
}
