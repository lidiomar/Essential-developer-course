//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Lidiomar Fernando dos Santos Machado on 12/10/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
