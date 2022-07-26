//
//  UnStarRepository.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/26.
//

import Foundation

struct UnStarRequest: Request {
    typealias Response = EmptyResponse
    var method: APIMethod = .delete
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
