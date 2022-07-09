//
//  Repository.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/09.
//

@preconcurrency import Foundation

struct Repository: Codable, Sendable {
    let id: Int
    let name: String
    let fullName: String
    let owner: User
    let `private`: Bool
    let description: String?
    let fork: Bool
    let url: String
    let createdAt: Date
    let updatedAt: Date
    let homepage: String?
    let stargazersCount: Int
    let watchersCount: Int
    let language: String?
    let forksCount: Int
    let license: GithubLicense?
}

