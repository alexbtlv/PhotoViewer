//
//  UnsplashEndPoint.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation
import Keys

public enum UnsplashApi {
    case popularPhotos(page: Int, offset: Int)
}

extension UnsplashApi: EndPointType {
    var path: String {
        return "photos"
    }
    
    var environmentBaseURL : String {
        return "https://api.unsplash.com/"
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var task: HTTPTask {
        switch self {
        case .popularPhotos(let page, let offset):
            let keys = PhotoViewerKeys()
            return .requestParameters(bodyParameters: nil, urlParameters: ["order_by":"popular",
                                                                           "page":page,
                                                                           "per_page":offset,
                                                                           "client_id":keys.unsplashAccessKey])
        }
    }
}
