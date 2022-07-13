//
//  UserDefaultsClientProtocol.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation

@dynamicMemberLookup
protocol UserDefaultsClientProtocol: AnyObject, Sendable {
    subscript<T>(dynamicMember keyPath: KeyPath<UserDefaultsClientKeys, UserDefaultsClientKey<T>>) -> T { get set }
}
