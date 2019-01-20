//
//  UnsplashSearchResults.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/20/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public struct UnsplashSearchResults: Decodable {
    let total: Int
    let total_pages: Int
    let results: [Photo]
}
