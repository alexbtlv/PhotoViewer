//
//  Photo.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation
import CoreGraphics

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
    let source: String?
    let width: Int
    let height: Int
    let author: User
    var aspectRatio: CGFloat {
        return CGFloat(width) / CGFloat(height)
    }
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
}


extension Photo: Codable {
    enum PhotoCodingKeys: String, CodingKey {
        case id
        case description
        case urls
        case links
        case width
        case height
        case user
    }
    
    public init(from decoder: Decoder) throws {
        let photoContainer = try decoder.container(keyedBy: PhotoCodingKeys.self)
        
        id = try photoContainer.decode(String.self, forKey: .id)
        description = try photoContainer.decode(String.self, forKey: .description)
        let urls = try photoContainer.decode([String:String].self, forKey: .urls)
        guard let thumb = urls["small"], let tURL = URL(string: thumb) else {
            throw DecodingError.missingThumbURL
        }
        thumbURL = tURL
        guard let raw = urls["full"], let rURL = URL(string: raw) else {
            throw DecodingError.missingRegularURL
        }
        regularURL = rURL
        let links = try photoContainer.decode([String:String].self, forKey: .links)
        guard let webSourceURL = links["html"] else {
            throw DecodingError.missingImageURL
        }
        source = webSourceURL
        width = try photoContainer.decode(Int.self, forKey: .width)
        height = try photoContainer.decode(Int.self, forKey: .height)
        author = try photoContainer.decode(User.self, forKey: .user)
    }
}
