//
//  ENVClient.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/13.
//

import Foundation

@dynamicMemberLookup
protocol ENVClientProtocol {
    subscript(dynamicMember keyPath: KeyPath<ENVKeys, String>) -> String { get }
}

@dynamicMemberLookup
struct ENVClient: Sendable, ENVClientProtocol {
    private let envKeys = ENVKeys()
    subscript(dynamicMember keyPath: KeyPath<ENVKeys, String>) -> String {
        ENV[envKeys[keyPath: keyPath]]!
    }
}

struct ENVKeys: Sendable {
    let githubAccessToken: String = "GITHUB_ACCESS_TOKEN"
}
