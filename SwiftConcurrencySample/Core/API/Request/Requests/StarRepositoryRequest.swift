//
//  StarRepositoryRequest.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation

struct StarRepositoryRequest: Request {
    typealias Response = EmptyResponse
    var method: APIMethod = .put
    var path: String
    var query: [String : String] = [:]
    var body: String? = nil
    
    init(
        ownerName: String,
        repositoryName: String
    ) {
        self.path = "/user/starred/\(ownerName)/\(repositoryName)"
    }
}

