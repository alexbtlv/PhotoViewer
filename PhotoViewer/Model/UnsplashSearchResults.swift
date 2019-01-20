//
//  UnsplashSearchResults.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/20/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public struct UnsplashSearchResults {
    let total: Int?
    let totalPages: Int?
    let results: [Photo]?
}


extension UnsplashSearchResults: Decodable {
    enum UnsplashSearchResultsCodingKeys: String, CodingKey {
        case total
        case total_pages
        case results
    }
    
    public init(from decoder: Decoder) throws {
        let resultContainer = try decoder.container(keyedBy: UnsplashSearchResultsCodingKeys.self)
        total = try resultContainer.decode(Int.self, forKey: .total)
        totalPages = try resultContainer.decode(Int.self, forKey: .total_pages)
        results = try resultContainer.decode([Photo].self, forKey: .results)
    }
}
