//
//  UserDefaultsClientKeys.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation

public struct UserDefaultsClientKey<T> {
    public let key: String
    public let defaultValue: T

    public init(
        key: String,
        defaultValue: T
    ) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public init(
        key: String,
        defaultValue: T = nil
    ) where T: ExpressibleByNilLiteral {
        self.key = key
        self.defaultValue = defaultValue
    }
}
