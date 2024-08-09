//
//  Created by Kumpels and Friends on 17.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation

public extension APIClient {
    @Sendable
    func news(searchTerm: String, regionID: Region.ID?) async throws -> [News] {
        let result: [NewsResponse] = try await decoded(
            for: .news(.search(searchTerm.isEmpty ? nil : searchTerm, regionId: regionID?.rawValue)),
            with: token
        )
        return result
            .map { News($0, baseURL: baseURL) }
            .sorted(using: [
                KeyPathComparator(\.date, order: .reverse)
            ])
    }

    @Sendable
    func fav(newsID: News.ID, shouldBeFaved: Bool) async throws -> News {
        let response: NewsResponse = try await decoded(
            for: .news(.singleNews(newsID.rawValue, shouldBeFaved ? .fav : .unfav)),
            with: token
        )
        return News(response, baseURL: baseURL)
    }

    @Sendable
    func favedNews() async throws -> [News] {
        let result: [NewsResponse] = try await decoded(
            for: .news(.faved),
            with: token
        )
        return result
            .map { News($0, baseURL: baseURL) }
            .sorted(using: [
                KeyPathComparator(\.date, order: .reverse)
            ])
    }

    @Sendable
    func markAsRead(newsID: News.ID) async throws {
        let client = URLRoutingClient.authenticated(apiURI: baseURI, token: token)
        let (_, response) = try await client.data(for: .news(.singleNews(newsID.rawValue, .markAsRead)))

        guard
            let response = response as? HTTPURLResponse,
            (200 ... 299).contains(response.statusCode)
        else {
            throw InvalidResponse()
        }
    }
}

extension News {
    init(_ rawValue: NewsResponse, baseURL: URL) {
        self.init(
            id: .init(rawValue: rawValue.uuid),
            title: rawValue.title,
            description: rawValue.description,
            teaser: rawValue.teaser ?? rawValue.description,
            date: rawValue.date,
            publishedDate: rawValue.publishedAt,
            tags: Set(rawValue.tags.map {
                Tag(id: .init(rawValue: $0.uuid), value: $0.value)
            }),
            image: .init(rawValue: rawValue.image, baseURL: baseURL),
            type: .init(rawValue.type),
            isFaved: rawValue.isFaved
        )
    }
}

extension News.NewsType {
    init(_ rawValue: NewsResponse.MagazineType?) {
        guard let rawValue else {
            self = .tip
            return
        }

        switch rawValue {
        case .news:
            self = .news
        case .tip:
            self = .tip
        }
    }
}
