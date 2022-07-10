//
//  UserTranslator.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation

enum UserTranslator {
    static func translateToUser(from entity: UserEntity) -> User {
        User(
            id: entity.id,
            login: entity.login,
            avatarUrl: entity.avatarUrl,
            url: entity.url,
            reposUrl: entity.reposUrl
        )
    }
}
