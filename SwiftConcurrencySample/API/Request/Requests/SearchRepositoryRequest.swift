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
    let body: String?

    init(
        query: [String: String],
        body: String? = nil
    ) {
        self.query = query
        self.body = body
    }
}

struct SearchRepositoryResponse: Decodable, Sendable {
    let totalCount: Int
    let items: [RepositoryEntity]
}
