//
//  Photo.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public enum DecodingError: String, Error {
    case missingThumbURL = "Missing Thumb image URL"
    case missingRegularURL = "Missing Regular image URL"
    case missingImageURL = "Missing link to web source"
}

public struct Photo {
    let id: String
    let description: String
    let thumbURL: URL
    let regularURL: URL
    let link: String
    let likes: Int
}


extension Photo: Decodable {
    enum PhotoCodingKeys: String, CodingKey {
        case id
        case description
        case urls
        case links
        case likes
    }
    
    public init(from decoder: Decoder) throws {
        let photoContainer = try decoder.container(keyedBy: PhotoCodingKeys.self)
        
        id = try photoContainer.decode(String.self, forKey: .id)
        description = try photoContainer.decode(String.self, forKey: .description)
        let urls = try photoContainer.decode([String:String].self, forKey: .urls)
        guard let thumb = urls["thumb"], let tURL = URL(string: thumb) else {
            throw DecodingError.missingThumbURL
        }
        thumbURL = tURL
        print(thumbURL)
        guard let regular = urls["regular"], let rURL = URL(string: regular) else {
            throw DecodingError.missingRegularURL
        }
        regularURL = rURL
        let links = try photoContainer.decode([String:String].self, forKey: .links)
        guard let webSourceURL = links["self"] else {
            throw DecodingError.missingImageURL
        }
        link = webSourceURL
        likes = try photoContainer.decode(Int.self, forKey: .likes)
    }
}
