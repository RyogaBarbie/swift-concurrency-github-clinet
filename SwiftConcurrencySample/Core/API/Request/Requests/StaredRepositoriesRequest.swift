//
//  StaredRepositoriesRequest.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/13.
//

import Foundation

struct StaredRepositoriesRequest: Request {
    typealias Response = StaredRepositoriesResponse

    var method: APIMethod = .get
    var path: String = "/user/starred"
    let query: [String: String]
    let body: String? = nil

    init(
        perPage: Int = 30,
        page: Int,
        sort: String = "created"
    ) {
        self.query = [
            "per_page": String(perPage),
            "page": String(page),
            "sort": sort
        ]
    }

}

typealias StaredRepositoriesResponse = [RepositoryEntity]
