//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Lidiomar Fernando dos Santos Machado on 13/10/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0, userInfo: nil)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
