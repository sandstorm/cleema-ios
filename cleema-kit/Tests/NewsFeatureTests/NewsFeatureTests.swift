//
//  Created by Kumpels and Friends on 10.12.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

import CombineSchedulers
import ComposableArchitecture
import Models
import NewsFeature
import XCTest

@MainActor
final class NewsFeatureTests: XCTestCase {
    func testFeature() async throws {
        let store = TestStore(
            initialState: .init(searchState: .init(region: Region.leipzig.id)),
            reducer: AllNews()
        )

        let expectedNews: [News] = [
            .fake(),
            .fake(),
            .fake()
        ]
        let tags: [Tag] = [.fake(value: "B"), .fake(value: "C"), .fake(value: "A")]
        store.dependencies.newsClient.news = { _, _ in expectedNews }
        store.dependencies.newsClient.tags = { tags }

        await store.send(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadingResponse(.success(expectedNews))) {
            $0.news = .init(uniqueElements: expectedNews)
            $0.isLoading = false
        }

        await store.receive(.tagsResponse(.success(tags))) {
            $0.searchState.suggestionState.tags = [tags[2], tags[0], tags[1]]
        }
    }

    func testFiltering() async {
        let store = TestStore(
            initialState: .init(searchState: .init(region: Region.leipzig.id)),
            reducer: AllNews()
        )
        let invokedTerm = ActorIsolated<String?>(nil)
        store.dependencies.newsClient.news = { term, region in
            await invokedTerm.setValue(term)
            return []
        }
        store.dependencies.newsClient.tags = { [] }
        await store.send(.search(.searchTerm("t", Region.leipzig.id))) {
            $0.searchState.term = "t"
        }

        await invokedTerm.withValue { value in
            XCTAssertNil(value)
        }

        await store.send(.search(.searchTerm("te", Region.leipzig.id))) {
            $0.searchState.term = "te"
        }

        await invokedTerm.withValue { value in
            XCTAssertNil(value)
        }

        await store.send(.search(.searchTerm("ter", Region.leipzig.id))) {
            $0.searchState.term = "ter"
        }

        await invokedTerm.withValue { value in
            XCTAssertNil(value)
        }

        await store.send(.search(.searchTerm("term", Region.leipzig.id))) {
            $0.searchState.term = "term"
        }

        await invokedTerm.withValue { value in
            XCTAssertNil(value)
        }

        await store.send(.search(.submit))

        await invokedTerm.withValue { value in
            XCTAssertEqual("term", value)
        }

        await store.receive(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadingResponse(.success([]))) {
            $0.isLoading = false
        }

        await store.receive(.tagsResponse(.success([])))
    }

    func testTagSuggestions() async {
        let tags = [Tag.fake(value: "Lorem"), .fake(value: "Leipzig"), .fake(value: "Dresden")]
        let store = TestStore(
            initialState: AllNews
                .State(searchState: .init(region: Region.leipzig.id, suggestionState: .init(tags: tags))),
            reducer: AllNews()
        )
        let invokedTerm = ActorIsolated<String?>(nil)
        store.dependencies.newsClient.news = { term, region in
            await invokedTerm.setValue(term)
            return []
        }
        store.dependencies.newsClient.tags = { [] }

        await store.send(.search(.searchTerm("Lo", Region.leipzig.id))) {
            $0.searchState.term = "Lo"
            $0.searchState.suggestionState.suggestions = [.tag(tags[0])]
        }

        await store.send(.search(.searchTerm("dre", Region.leipzig.id))) {
            $0.searchState.term = "dre"
            $0.searchState.suggestionState.suggestions = [.tag(tags[2])]
        }

        await store.send(.search(.suggestions(.suggestion(id: tags[2].id.rawValue, action: .tapped)))) {
            $0.searchState.suggestionState.suggestions = []
            $0.searchState.term = tags[2].value
        }

        await store.receive(.search(.submit))

        await store.receive(.load) {
            $0.isLoading = true
        }

        await store.receive(.loadingResponse(.success([]))) {
            $0.isLoading = false
        }
        await store.receive(.tagsResponse(.success([]))) {
            $0.searchState.suggestionState.tags = []
        }
    }

    func testTappingOnTagsInNews() async throws {
        let expectedNews: [News] = [
            .fake(tags: [.fake()]),
            .fake(tags: [.fake()]),
            .fake(tags: [.fake()])
        ]
        let store = TestStore(
            initialState: .init(
                news: .init(uniqueElements: expectedNews),
                searchState: .init(region: Region.leipzig.id)
            ),
            reducer: AllNews()
        )

        let invokedTerm = ActorIsolated<String?>(nil)
        store.dependencies.newsClient.news = { term, region in
            await invokedTerm.setValue(term)
            return expectedNews
        }
        store.dependencies.newsClient.tags = { [] }

        let expectedTag = expectedNews[0].tags[0]
        await store.send(.news(id: expectedNews[0].id, action: .tagTapped(expectedTag))) {
            $0.searchState.term = expectedTag.value
        }

        await store.receive(.load) {
            $0.isLoading = true
        }

        await invokedTerm.withValue { value in
            XCTAssertEqual(expectedTag.value, value)
        }

        await store.receive(.loadingResponse(.success(expectedNews))) {
            $0.isLoading = false
        }

        await store.receive(.tagsResponse(.success([])))
    }

    func testTappingOnFavButton() async throws {
        let id = News.ID(UUID())

        let invokedFaved = ActorIsolated<(News.ID, Bool)?>(nil)
        let favedNews = News.fake(id: id, isFaved: false)

        let store = TestStore(
            initialState: .init(
                news: .init(uniqueElements: [.fake(id: id, isFaved: false)]),
                searchState: .init(region: Region.leipzig.id)
            ),
            reducer: AllNews()
        ) {
            $0.newsClient.fav = { id, faved in
                await invokedFaved.setValue((id, faved))
                return favedNews
            }
        }

        await store.send(.news(id: id, action: .favoriteTapped)) {
            var news = $0.news
            news[id: id]?.isFaved = true
            $0.news = news
        }

        await invokedFaved.withValue { value in
            XCTAssertEqual(id, value?.0)
            XCTAssertEqual(true, value?.1)
        }

        await store.receive(.news(id: id, action: .singleNewsResponse(.success(favedNews)))) {
            $0.news[id: id] = favedNews
        }
    }

    func testTappingOnFavButtonInDetails() async throws {
        let invokedFaved = ActorIsolated<(News.ID, Bool)?>(nil)
        let selectedNews = News.fake(isFaved: false)
        let favedNews = News.fake()

        let store = TestStore(
            initialState: .init(
                news: .init(uniqueElements: [selectedNews]),
                searchState: .init(region: Region.leipzig.id),
                selection: .init(selectedNews, id: selectedNews.id)
            ),
            reducer: AllNews()
        ) {
            $0.newsClient.fav = { id, faved in
                await invokedFaved.setValue((id, faved))
                return favedNews
            }
        }

        await store.send(.newsDetail(.favoriteTapped))

        await invokedFaved.withValue { value in
            XCTAssertEqual(selectedNews.id, value?.0)
            XCTAssertEqual(!selectedNews.isFaved, value?.1)
        }

        await store.receive(.newsDetail(.singleNewsResponse(.success(favedNews)))) {
            $0.selection = .init(favedNews, id: selectedNews.id)
        }

        await store.send(.newsDetail(.favoriteTapped))

        await invokedFaved.withValue { value in
            XCTAssertEqual(favedNews.id, value?.0)
            XCTAssertEqual(!favedNews.isFaved, value?.1)
        }

        await store.receive(.newsDetail(.singleNewsResponse(.success(favedNews))))
    }
}
