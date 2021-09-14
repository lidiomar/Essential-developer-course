//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Lidiomar Fernando dos Santos Machado on 17/08/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
