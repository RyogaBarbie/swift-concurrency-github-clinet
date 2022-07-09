//
//  GithubLicense.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/09.
//

import Foundation

struct GithubLicense: Codable, Sendable {
    let key: String
    let name: String
    let url: String?
}
