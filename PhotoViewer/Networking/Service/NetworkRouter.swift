//
//  NetworkRouter.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completetion: @escaping NetworkRouterCompletion)
    func cancel()
}
