//
//  SearchRepositoryRequest.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/09.
//

import Foundation

struct SearchRepositoryRequest: Request {
    typealias Response = SearchRepositoryResponse
    let method: APIMethod = .get
    let path: String = "/search/repositories"
    let query: [String: String]
    let body: String? = nil

    init(
        keyword: String,
        perPage: Int = 30,
        page: Int,
        sort: String = "stars",
        order: String = "desc"
    ) {
        self.query = [
            "q": keyword,
            "per_page": String(perPage),
            "page": String(page),
            "sort": sort,
            "order": order
        ]
    }
}

struct SearchRepositoryResponse: Decodable, Sendable {
    let totalCount: Int
    let items: [RepositoryEntity]
}
