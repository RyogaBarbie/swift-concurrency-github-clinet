//
//  ENVClient.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/13.
//

import Foundation

@dynamicMemberLookup
protocol ENVClientProtocol {
    subscript(dynamicMember key: String) -> String { get }
}

@dynamicMemberLookup
struct ENVClient: Sendable {
    private let envKeys = ENVKeys()
    subscript(dynamicMember keyPath: KeyPath<ENVKeys, String>) -> String {
        ENV[envKeys[keyPath: keyPath]]!
    }
}

struct ENVKeys: Sendable {
    let githubAccessToken: String = "GITHUB_ACCESS_TOKEN"
}
