//
//  UserDefaultsClientKeys.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation

public struct UserDefaultsClientKeys: Sendable {
    public init() {}

    public var searchKeywordHistories: UserDefaultsClientKey<[String]> { .init(key: "searchKeywordHistories", defaultValue: [])}
}
