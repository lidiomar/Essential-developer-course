//
//  FeedViewControllerTests.swift
//  EssentialFeedTests
//
//  Created by Lidiomar Machado on 09/01/22.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedAcions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator())
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator())
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator())
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator())
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator(), false)
    }
    
    func test_loadFeedCompletion_renderSuccessfullyRenderFeed() {
        let imageFeed0 = makeImage(description: "a description", location: "a location")
        let imageFeed1 = makeImage(description: nil, location: "another location")
        let imageFeed2 = makeImage(description: "another description", location: nil)
        let imageFeed3 = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(feed: [imageFeed0])
        assertThat(sut, isRendering: [imageFeed0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(feed: [imageFeed0, imageFeed1, imageFeed2, imageFeed3])
        assertThat(sut, isRendering: [imageFeed0, imageFeed1, imageFeed2, imageFeed3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let imageFeed0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(at: 0, feed: [imageFeed0])
        assertThat(sut, isRendering: [imageFeed0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoaderWithError(at: 0)
        assertThat(sut, isRendering: [imageFeed0])
    }

    
    // MARK: - Helpers
    
    private func assertThat(_ sut: FeedViewController,
                            isRendering feedImages: [FeedImage],
                            file: StaticString = #file,
                            line: UInt = #line) {
        
        guard sut.numberOfRenderedFeedImageViews() == feedImages.count else {
            XCTFail("Expected \(feedImages.count) got \(sut.numberOfRenderedFeedImageViews()) instead")
            return
        }
        
        feedImages.enumerated().forEach { index, element in
            assertThat(sut, hasConfigured: element, at: index, file: file, line: line)
        }
        
    }
    
    private func assertThat(_ sut: FeedViewController,
                            hasConfigured feedImage: FeedImage,
                            at index: Int,
                            file: StaticString = #file,
                            line: UInt = #line) {
        
        let view = sut.feedImageView(at: index) as! FeedImageCell
        
        XCTAssertEqual(view.isShowingLocation,
                       (feedImage.location != nil),
                       "Expected to be \((feedImage.location != nil))",
                       file: file,
                       line: line)
        
        XCTAssertEqual(view.locationText,
                       feedImage.location,
                       "Expected to be \(String(describing: feedImage.location))",
                       file: file,
                       line: line)
        
        XCTAssertEqual(view.descriptionText,
                       feedImage.description,
                       "Expected to be \(String(describing: feedImage.description))",
                       file: file,
                       line: line)
    }
    
    private func makeImage(description: String? = nil,
                           location: String? = nil,
                           url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    
    class LoaderSpy: FeedLoader {
        var loadCallCount: Int {
            return completions.count
        }
        
        private var completions = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0, feed: [FeedImage] = []) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoaderWithError(at index: Int = 0) {
            let error = NSError(domain: "error", code: 0)
            completions[index](.failure(error))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: section)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
    }
    
    private var section: Int {
        return 0
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
