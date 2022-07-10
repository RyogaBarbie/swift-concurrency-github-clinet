//
//  RepositoryTranslator.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation

enum RepositoryTranslator {
    static func translateToRepository(from entity: RepositoryEntity) -> Repository {
        Repository(
            id: entity.id,
            name: entity.name,
            fullName: entity.fullName,
            owner: UserTranslator.translateToUser(from: entity.owner),
            private: entity.private,
            description: entity.description,
            fork: entity.fork,
            url: entity.url,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            homepage: entity.homepage,
            stargazersCount: entity.stargazersCount,
            watchersCount: entity.watchersCount,
            language: entity.language,
            forksCount: entity.forksCount,
            license: entity.license
        )
    }
}
