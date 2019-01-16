//
//  NetworkError.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public enum NetworkError: String, Error {
    case noInternetConnection = "Can not establish internect connection"
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil"
}
