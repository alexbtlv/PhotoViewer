//
//  User.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/18/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public struct User {
    let id: String
    let name: String
    let profileImageURL: URL
}

extension User: Decodable {
    enum UserCodingKeys: String, CodingKey {
        case id
        case name
        case profile_image
    }
    
    public init(from decoder: Decoder) throws {
        let userContainer = try decoder.container(keyedBy: UserCodingKeys.self)
        
        id = try userContainer.decode(String.self, forKey: .id)
        name = try userContainer.decode(String.self, forKey: .name)
        let profileImageURLS = try userContainer.decode([String:String].self, forKey: .profile_image)
        guard let userPic = profileImageURLS["medium"], let url = URL(string: userPic) else {
            throw DecodingError.missingImageURL
        }
        profileImageURL = url
    }
}
