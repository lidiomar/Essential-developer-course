//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Lidiomar Fernando dos Santos Machado on 17/08/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
