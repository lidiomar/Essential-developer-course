//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Lidiomar Machado on 11/01/22.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            switch result {
            case let .success(feedImage):
                self?.tableModel = feedImage
                self?.tableModel = (try? result.get()) ?? []
                self?.tableView.reloadData()
            case .failure:
                break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let feedImageCell = FeedImageCell()
        feedImageCell.locationContainer.isHidden = (cellModel.location == nil)
        feedImageCell.descriptionLabel.text = cellModel.description
        feedImageCell.locationLabel.text = cellModel.location
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url)
        
        return feedImageCell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}
