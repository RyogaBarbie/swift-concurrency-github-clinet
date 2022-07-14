//
//  StaredRepositoryBuilder.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation

enum StaredRepositoryBuilder {
    @MainActor static func build(
        apiClient: APIClientProtocol,
        userDefaultsClient: UserDefaultsClientProtocol
    ) -> StaredRepositoryHostingController {
        let viewModel = StaredRepositoryViewModel(
            state: .init(repositories: []),
            environment: .init(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient
            )
        )
        return StaredRepositoryHostingController(
            StaredRepositoryView(
                viewModel: viewModel
            ),
            viewModel: viewModel
        )
    }
}
