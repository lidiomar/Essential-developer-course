//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Lidiomar Fernando dos Santos Machado on 17/08/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
