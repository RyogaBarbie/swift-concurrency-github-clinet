//
//  UserDefaultsClient.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

@preconcurrency import Foundation

@dynamicMemberLookup
//actor UserDefaultsClient: UserDefaultsClientProtocol {
final class UserDefaultsClient: UserDefaultsClientProtocol {
    private let keys = UserDefaultsClientKeys()
    private let userDefaults: UserDefaults
    
    init(
        userDefaults: UserDefaults
    ) {
        self.userDefaults = userDefaults
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<UserDefaultsClientKeys, UserDefaultsClientKey<T>>) -> T {
        get {
            let key = keys[keyPath: keyPath]
            return userDefaults.object(forKey: key.key) as? T ?? key.defaultValue
        }
        set {
            let key = keys[keyPath: keyPath]
            userDefaults.set(newValue, forKey: key.key)
        }
    }

    subscript<T: OptionalType>(dynamicMember keyPath: KeyPath<UserDefaultsClientKeys, UserDefaultsClientKey<T>>) -> T {
        get {
            let key = keys[keyPath: keyPath]
            let value = userDefaults.object(forKey: key.key) as? T ?? key.defaultValue
            return value
        }
        set {
            let key = keys[keyPath: keyPath]
            let value = newValue as? T.Wrapped

            if value.isNil {
                userDefaults.removeObject(forKey: key.key)
            } else {
                userDefaults.set(newValue, forKey: key.key)
            }
        }
    }
}

protocol OptionalType {
    associatedtype Wrapped
}

extension Optional: OptionalType {
    var isNil: Bool {
        return self == nil
    }
}
