//
//  CheckStarRequest.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation

struct CheckStarRequest: Request {
    typealias Response = Bool
    var method: APIMethod = .get
    var path: String
    var query: [String : String] = ["q": "hoge"]
    var body: String? = nil
    
    init(
        ownerName: String,
        repositoryName: String
    ) {
        self.path = "/user/starred/\(ownerName)/\(repositoryName)"
    }
}
