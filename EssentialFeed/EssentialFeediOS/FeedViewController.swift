//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Lidiomar Machado on 11/01/22.
//

import Foundation
import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            self?.refreshControl?.endRefreshing()
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
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
        
        return feedImageCell
    }
}
