//
//  User.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/09.
//

import Foundation

struct User: Codable, Sendable {
    let id: Int
    let login: String
    let avatarUrl: String
    let url: String
    let reposUrl: String
}
