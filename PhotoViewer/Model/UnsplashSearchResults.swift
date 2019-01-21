//
//  UnsplashSearchResults.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/20/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public struct UnsplashSearchResults {
    let results: [Photo]?
}

extension UnsplashSearchResults: Decodable {
    enum UnsplashSearchResultsCodingKeys: String, CodingKey {
        case results
    }
    
    public init(from decoder: Decoder) throws {
        let resultContainer = try decoder.container(keyedBy: UnsplashSearchResultsCodingKeys.self)
        let failableResults = try resultContainer.decode(FailableCodableArray<Photo>.self, forKey: .results)
        results = failableResults.elements
    }
}
