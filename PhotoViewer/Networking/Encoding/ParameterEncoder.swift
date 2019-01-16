//
//  ParameterEncoder.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public typealias Parameters = [String:Any]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}
