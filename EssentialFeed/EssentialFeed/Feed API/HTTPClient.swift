//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Lidiomar Fernando dos Santos Machado on 18/09/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
