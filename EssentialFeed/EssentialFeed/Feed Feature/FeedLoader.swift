//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Lidiomar Fernando dos Santos Machado on 17/08/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
